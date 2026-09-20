#!/usr/bin/env bash
# Audit pinned skill repositories, optionally updating refs to upstream HEAD.
set -euo pipefail

write=false
if [[ ${1-} == "--write" ]]; then
	write=true
elif [[ $# -gt 0 ]]; then
	echo "Usage: $0 [--write]" >&2
	exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
manifest="${repo_root}/skills.yaml"

records="$(mktemp)"
next_manifest="$(mktemp)"
trap 'rm -f "${records}" "${next_manifest}"' EXIT

awk '
  /^  - repository: / {
    repository = $0
    sub(/^  - repository: "/, "", repository)
    sub(/"$/, "", repository)
  }
  /^    ref: / {
    ref = $0
    sub(/^    ref: "/, "", ref)
    sub(/"$/, "", ref)
    print repository "\t" ref
  }
' "${manifest}" >"${records}"

updates=0
while IFS=$'\t' read -r repository current_ref; do
	[[ -n ${repository} && -n ${current_ref} ]] || continue
	latest_ref="$(git ls-remote "https://github.com/${repository}.git" HEAD | awk '{print $1}')"
	if [[ -z ${latest_ref} ]]; then
		echo "Error: could not resolve HEAD for ${repository}." >&2
		exit 1
	fi

	if [[ ${current_ref} == "${latest_ref}" ]]; then
		echo "current  ${repository}  ${current_ref:0:12}"
		continue
	fi

	updates=$((updates + 1))
	echo "update   ${repository}  ${current_ref:0:12} -> ${latest_ref:0:12}"
	if [[ ${write} == true ]]; then
		awk -v target="${repository}" -v replacement="${latest_ref}" '
          $0 == "  - repository: \"" target "\"" { in_target = 1 }
          in_target && /^    ref: / {
            $0 = "    ref: \"" replacement "\""
            in_target = 0
          }
          { print }
        ' "${manifest}" >"${next_manifest}"
		mv "${next_manifest}" "${manifest}"
	fi
done <"${records}"

if ((updates == 0)); then
	echo "All pinned skill repositories are current."
elif [[ ${write} == false ]]; then
	echo "Run $0 --write to update the pinned refs, then review and reinstall."
else
	echo "Updated ${manifest}; review the diff before installing."
fi
