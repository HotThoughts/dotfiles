#!/usr/bin/env bash
# Install the exact skill revisions declared in skills.yaml.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
manifest="${repo_root}/skills.yaml"

if ! command -v node >/dev/null 2>&1; then
	echo "Error: Node.js is required to install agent skills." >&2
	exit 1
fi

cli_version="$(sed -nE 's/^cli_version: "([^"]+)"$/\1/p' "${manifest}")"
if [[ -z ${cli_version} ]]; then
	echo "Error: cli_version is missing from ${manifest}." >&2
	exit 1
fi

mapfile_path="$(mktemp)"
trap 'rm -f "${mapfile_path}"' EXIT

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
  }
  /^      - / {
    path = $0
    sub(/^      - "/, "", path)
    sub(/"$/, "", path)
    print repository "\t" ref "\t" path
  }
' "${manifest}" >"${mapfile_path}"

while IFS=$'\t' read -r repository ref skill_path; do
	[[ -n ${repository} && -n ${ref} && -n ${skill_path} ]] || continue
	url="https://github.com/${repository}/tree/${ref}/${skill_path}"
	echo "Installing ${repository}/${skill_path##*/} at ${ref:0:12}"
	npx --yes "skills@${cli_version}" add "${url}" --global \
		--agent codex claude-code opencode github-copilot --yes </dev/null
done <"${mapfile_path}"
