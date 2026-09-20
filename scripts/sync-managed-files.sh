#!/usr/bin/env bash
#
# List managed files whose $HOME copy diverged from the chezmoi source state,
# and optionally re-add exactly those files with `chezmoi re-add`.
#
# Self-modifying tools (atuin, herdr, zed, omp, ...) rewrite their own files in
# $HOME, which silently drifts the source repository. This script is the audit
# step before committing.
#
# It never calls `chezmoi apply`, `update`, `forget`, or `diff`, and it never
# renders templates: it reads only `chezmoi managed`, `chezmoi source-path`, and
# `chezmoi state dump`, so it keeps working on machines where some template
# would fail to render.

set -euo pipefail

usage() {
	cat <<'EOF'
Usage: scripts/sync-managed-files.sh [--write] [--force]

  (no flags)  audit only: list drift and print conflict diffs
  --write     re-add unambiguous drift with `chezmoi re-add`
  --force     with --write: also re-add conflicting/unclassified files
EOF
}

write=false
force=false
while [[ $# -gt 0 ]]; do
	case "$1" in
	--write)
		write=true
		;;
	--force)
		force=true
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Error: unknown argument: $1" >&2
		usage >&2
		exit 2
		;;
	esac
	shift
done

if [[ ${force} == true && ${write} == false ]]; then
	echo "Error: --force requires --write." >&2
	usage >&2
	exit 2
fi

for dependency in chezmoi jq shasum; do
	if ! command -v "${dependency}" >/dev/null 2>&1; then
		echo "Error: ${dependency} is not installed." >&2
		exit 1
	fi
done

home="${HOME%/}"
# A literal '~' in a ${var/#pat/repl} replacement would be tilde-expanded, so
# substitute it from a variable instead.
home_prefix="~"

# Managed targets, without rendering templates or externals. A missing template
# dependency would otherwise abort the whole `chezmoi status`/`diff` run.
targets=()
while IFS= read -r line; do
	[[ -n ${line} ]] || continue
	targets+=("${line}")
done < <(chezmoi managed --path-style absolute -x templates,externals)

# `chezmoi re-add` only acts on regular files, so classify just those; separately
# record managed targets that are absent from $HOME (a plain `chezmoi apply`
# recreates them).
files=()
missing=()
for target in ${targets[@]+"${targets[@]}"}; do
	if [[ ! -e ${target} ]]; then
		missing+=("${target}")
	elif [[ -f ${target} && ! -L ${target} ]]; then
		files+=("${target}")
	fi
done

sources=()
if ((${#files[@]} > 0)); then
	while IFS= read -r line; do
		sources+=("${line}")
	done < <(chezmoi source-path "${files[@]}")
fi

if ((${#sources[@]} != ${#files[@]})); then
	echo "Error: chezmoi source-path returned ${#sources[@]} paths for ${#files[@]} targets." >&2
	exit 1
fi

# .entryState[<target>].contentsSHA256 is the hash chezmoi last wrote to $HOME.
state_file="$(mktemp)"
trap 'rm -f "${state_file}"' EXIT
chezmoi state dump --format json |
	jq -r '.entryState | to_entries[] | [.key, (.value.contentsSHA256 // "")] | @tsv' >"${state_file}"

state_hash_for() {
	awk -F '\t' -v target="$1" '$1 == target { print $2; exit }' "${state_file}"
}

source_for() {
	local target="$1" i
	if ((${#files[@]} == 0)); then
		return 1
	fi
	for i in "${!files[@]}"; do
		if [[ ${files[$i]} == "${target}" ]]; then
			printf '%s\n' "${sources[$i]}"
			return 0
		fi
	done
	return 1
}

re_add=()
conflicts=()
unknown=()
apply_list=()
stale=()
in_sync=0

for target in ${files[@]+"${files[@]}"}; do
	source="$(source_for "${target}")"
	dest_hash="$(shasum -a 256 "${target}" | awk '{print $1}')"
	src_hash="$(shasum -a 256 "${source}" | awk '{print $1}')"
	state_hash="$(state_hash_for "${target}")"

	if [[ -z ${state_hash} ]]; then
		# Never applied by this source state: identical bytes are fine, otherwise
		# chezmoi has no record of what it wrote.
		if [[ ${dest_hash} == "${src_hash}" ]]; then
			in_sync=$((in_sync + 1))
		else
			unknown+=("${target}")
		fi
	elif [[ ${dest_hash} == "${state_hash}" && ${src_hash} == "${state_hash}" ]]; then
		in_sync=$((in_sync + 1))
	elif [[ ${dest_hash} == "${state_hash}" ]]; then
		# Source changed since the last apply; `chezmoi apply` updates $HOME.
		apply_list+=("${target}")
	elif [[ ${src_hash} == "${state_hash}" ]]; then
		# Destination changed outside chezmoi; a clean re-add candidate.
		re_add+=("${target}")
	elif [[ ${dest_hash} == "${src_hash}" ]]; then
		# Already identical to the source; nothing to record.
		stale+=("${target}")
	else
		# Both sides changed since the last apply; needs review.
		conflicts+=("${target}")
	fi
done

print_group() {
	local status="$1"
	shift
	local target
	for target in "$@"; do
		printf '%-9s %s\n' "${status}" "${target/#${home}/${home_prefix}}"
	done
}

if ((${#re_add[@]} > 0)); then
	print_group "re-add" "${re_add[@]}"
fi

if ((${#conflicts[@]} > 0)); then
	print_group "conflict" "${conflicts[@]}"
	for target in "${conflicts[@]}"; do
		diff -u "$(source_for "${target}")" "${target}" | sed 's/^/  /' || true
	done
fi

if ((${#unknown[@]} > 0)); then
	print_group "unknown" "${unknown[@]}"
fi

if ((${#missing[@]} > 0)); then
	print_group "missing" "${missing[@]}"
fi

if ((${#apply_list[@]} > 0)); then
	print_group "apply" "${apply_list[@]}"
fi

if ((${#stale[@]} > 0)); then
	print_group "stale" "${stale[@]}"
fi

printf 'Summary: %d re-add, %d conflict, %d unknown, %d missing, %d apply, %d stale, %d in sync\n' \
	"${#re_add[@]}" "${#conflicts[@]}" "${#unknown[@]}" "${#missing[@]}" "${#apply_list[@]}" "${#stale[@]}" "${in_sync}"

if [[ ${write} == false ]]; then
	if ((${#re_add[@]} > 0 || ${#conflicts[@]} > 0 || ${#unknown[@]} > 0)); then
		echo "Run $0 --write to re-add clean drift; review conflict diffs first."
	fi
	exit 0
fi

re_added=0
if ((${#re_add[@]} > 0)); then
	chezmoi re-add "${re_add[@]}"
	re_added=$((re_added + ${#re_add[@]}))
fi

forced=()
if [[ ${force} == true ]]; then
	if ((${#conflicts[@]} > 0)); then
		forced+=("${conflicts[@]}")
	fi
	if ((${#unknown[@]} > 0)); then
		forced+=("${unknown[@]}")
	fi
fi
if ((${#forced[@]} > 0)); then
	chezmoi re-add "${forced[@]}"
	re_added=$((re_added + ${#forced[@]}))
fi

if ((re_added > 0)); then
	echo "Re-added ${re_added} file(s). Review with: jj diff"
	echo "Verify with: bash tests/run.sh"
fi

if [[ ${force} == false ]]; then
	if ((${#conflicts[@]} > 0)); then
		echo
		echo "Skipped ${#conflicts[@]} conflict(s); review the diff(s) above, then:"
		for target in "${conflicts[@]}"; do
			echo "  chezmoi re-add ${target/#${home}/${home_prefix}}  # after reviewing the diff above"
		done
		echo "Rerun with --force to include them in this run."
	fi
	if ((${#unknown[@]} > 0)); then
		echo
		echo "Skipped ${#unknown[@]} unclassified file(s) with no state record; pass --force to re-add them."
	fi
fi

exit 0
