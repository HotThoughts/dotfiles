#!/usr/bin/env bash
#
# Discover configuration files in $HOME that chezmoi does not manage, and
# optionally add them to the chezmoi source state.
#
# New tools write config into $HOME/.config (and scripts into $HOME/.local/bin)
# without anyone running `chezmoi add`. This script is the discovery step: it
# lists plausible config candidates, keeps credential-looking files out of the
# default set, and skips generated caches and tool state.
#
# Like scripts/sync-managed-files.sh, it never renders templates: it only reads
# `chezmoi unmanaged` and calls `chezmoi add` on request.

set -euo pipefail

usage() {
	cat <<'EOF'
Usage: scripts/sync-new-configs.sh [--write] [--path PATH]...

  (no flags)     audit only: list candidate config files
  --write        add the listed candidates with `chezmoi add`
  --path PATH    force-include PATH, bypassing all filters (repeatable)
EOF
}

write=false
extra_paths=()
while [[ $# -gt 0 ]]; do
	case "$1" in
	--write)
		write=true
		;;
	--path)
		if [[ $# -lt 2 ]]; then
			echo "Error: --path requires an argument." >&2
			usage >&2
			exit 2
		fi
		extra_paths+=("$2")
		shift
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

if ! command -v chezmoi >/dev/null 2>&1; then
	echo "Error: chezmoi is not installed." >&2
	exit 1
fi

home="${HOME%/}"
# A literal '~' in a ${var/#pat/repl} replacement would be tilde-expanded, so
# substitute it from a variable instead.
home_prefix="~"
roots=("${home}/.config/" "${home}/.local/bin/")

matches_include() {
	case "$1" in
	config | config.* | *.toml | *.yaml | *.yml | *.kdl | *.conf | *.ini | *.jsonc | *.lua | *.fish | *.sh)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

is_excluded() {
	local path="$1" base
	base="${path##*/}"
	case "${path}" in
	"${home}/.config/chezmoi/"* | "${home}/.config/fish/functions/"* | "${home}/.config/fish/completions/"* | "${home}/.config/nvim/lazy/"* | "${home}/.config/nvim/plugin/"*)
		return 0
		;;
	esac
	case "${base}" in
	*.backup | *.bak | *.lock | *.log | *.db | *.db-shm | *.db-wal | *.sqlite | *.sqlite3 | *.tmp)
		return 0
		;;
	esac
	case "${base}" in
	state.yml | state.json | fish_variables | settings_backup.json | chezmoi.toml | chezmoistate.boltdb)
		return 0
		;;
	esac
	return 1
}

is_sensitive() {
	local path="$1" base
	base="${path##*/}"
	case "${path}" in
	"${home}/.config/gh/"* | "${home}/.config/gcloud/"*)
		return 0
		;;
	esac
	grep -Eiq 'secret|token|credential|password|api[_-]?key|private[_-]?key|id_rsa|netrc|hosts\.yml' <<<"${base}"
}

candidates=()
sensitive=()
filtered=0

while IFS= read -r path; do
	[[ -n ${path} ]] || continue

	under_root=false
	for root in "${roots[@]}"; do
		if [[ ${path} == "${root}"* ]]; then
			under_root=true
			break
		fi
	done
	[[ ${under_root} == true ]] || continue
	[[ -f ${path} && ! -L ${path} ]] || continue

	# Credential-looking files are reported but never default-added, even when
	# their extension is not a config extension.
	if is_sensitive "${path}"; then
		sensitive+=("${path}")
		filtered=$((filtered + 1))
		continue
	fi
	if ! matches_include "${path##*/}"; then
		filtered=$((filtered + 1))
		continue
	fi
	if is_excluded "${path}"; then
		filtered=$((filtered + 1))
		continue
	fi
	candidates+=("${path}")
done < <(chezmoi unmanaged --path-style absolute -i files)

extras=()
for path in ${extra_paths[@]+"${extra_paths[@]}"}; do
	[[ ${path} == /* ]] || path="${PWD}/${path}"
	duplicate=false
	for candidate in ${candidates[@]+"${candidates[@]}"}; do
		if [[ ${candidate} == "${path}" ]]; then
			duplicate=true
			break
		fi
	done
	if [[ ${duplicate} == true ]]; then
		continue
	fi
	extras+=("${path}")
done

for candidate in ${candidates[@]+"${candidates[@]}"}; do
	printf 'candidate  %s\n' "${candidate/#${home}/${home_prefix}}"
done

echo "Sensitive (never auto-added):"
for path in ${sensitive[@]+"${sensitive[@]}"}; do
	printf '  %s\n' "${path/#${home}/${home_prefix}}"
done

if ((${#extras[@]} > 0)); then
	echo "Additional (--path):"
	for path in "${extras[@]}"; do
		printf '  %s\n' "${path/#${home}/${home_prefix}}"
	done
fi

printf '%d other unmanaged files under these roots were filtered out (use --path PATH to add one explicitly).\n' "${filtered}"

if [[ ${write} == false ]]; then
	if ((${#candidates[@]} > 0 || ${#extras[@]} > 0)); then
		echo "Run $0 --write to add the candidates above."
	fi
	exit 0
fi

to_add=()
if ((${#candidates[@]} > 0)); then
	to_add+=("${candidates[@]}")
fi
if ((${#extras[@]} > 0)); then
	to_add+=("${extras[@]}")
fi

failed=false
if ((${#to_add[@]} == 0)); then
	echo "Nothing to add."
elif chezmoi add --secrets=error "${to_add[@]}"; then
	echo "Added ${#to_add[@]} file(s). Review with: jj diff"
else
	echo "Error: chezmoi add failed; no files were added." >&2
	failed=true
fi

for path in ${sensitive[@]+"${sensitive[@]}"}; do
	echo "WARNING: ${path/#${home}/${home_prefix}} looks like a credential store; if it must be managed, convert it to a template that reads from the keychain (AGENTS.md) instead of adding the rendered file." >&2
done

if [[ ${failed} == true ]]; then
	exit 1
fi

exit 0
