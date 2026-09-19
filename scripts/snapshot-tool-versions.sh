#!/usr/bin/env bash
# Record installed versions of direct Brewfile entries.
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
	echo "Error: Homebrew is not installed." >&2
	exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
brewfile="${repo_root}/Brewfile"
snapshot="${repo_root}/Brewfile.versions"
to_stdout=false

if [[ ${1-} == "--stdout" ]]; then
	to_stdout=true
elif [[ $# -gt 0 ]]; then
	echo "Usage: $0 [--stdout]" >&2
	exit 2
fi

if ! formula_list="$(brew bundle list --file="${brewfile}" --formula)"; then
	echo "Error: could not read formulae from ${brewfile}" >&2
	exit 1
fi
if ! cask_list="$(brew bundle list --file="${brewfile}" --cask)"; then
	echo "Error: could not read casks from ${brewfile}" >&2
	exit 1
fi

write_snapshot() {
	echo "# Installed versions of direct Brewfile entries."
	echo "# This is an inventory for reviewing changes, not an exact-version lock."
	printf "type\ttool\tversion\n"

	local kind list item installed versions
	for kind in formula cask; do
		if [[ ${kind} == formula ]]; then
			list="${formula_list}"
		else
			list="${cask_list}"
		fi
		while IFS= read -r item; do
			[[ -z ${item} ]] && continue
			if [[ ${kind} == formula ]]; then
				installed="$(brew list --versions "${item}" 2>/dev/null || true)"
			else
				installed="$(brew list --cask --versions "${item}" 2>/dev/null || true)"
			fi
			if [[ -n ${installed} ]]; then
				versions="${installed#* }"
			else
				versions="<not-installed>"
			fi
			printf "%s\t%s\t%s\n" "${kind}" "${item}" "${versions}"
		done <<<"${list}"
	done
}

if [[ ${to_stdout} == true ]]; then
	write_snapshot
else
	temp_snapshot="$(mktemp "${repo_root}/.Brewfile.versions.XXXXXX")"
	trap 'rm -f "$temp_snapshot"' EXIT
	write_snapshot >"${temp_snapshot}"
	mv "${temp_snapshot}" "${snapshot}"
	trap - EXIT
	echo "Updated ${snapshot}"
fi
