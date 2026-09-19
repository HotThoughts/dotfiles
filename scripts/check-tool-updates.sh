#!/usr/bin/env bash
# Report updates for direct Brewfile entries and summarize upstream releases.
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
	echo "Error: Homebrew is not installed." >&2
	exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
brewfile="${repo_root}/Brewfile"
include_release_notes=true

if [[ ${1-} == "--no-release-notes" ]]; then
	include_release_notes=false
elif [[ $# -gt 0 ]]; then
	echo "Usage: $0 [--no-release-notes]" >&2
	exit 2
fi

formulae=()
casks=()
if ! formula_list="$(brew bundle list --file="${brewfile}" --formula)"; then
	echo "Error: could not read formulae from ${brewfile}" >&2
	exit 1
fi
if ! cask_list="$(brew bundle list --file="${brewfile}" --cask)"; then
	echo "Error: could not read casks from ${brewfile}" >&2
	exit 1
fi
while IFS= read -r item; do
	[[ -z ${item} ]] || formulae+=("${item}")
done <<<"${formula_list}"
while IFS= read -r item; do
	[[ -z ${item} ]] || casks+=("${item}")
done <<<"${cask_list}"

formula_err="$(mktemp)"
cask_err="$(mktemp)"
trap 'rm -f "$formula_err" "$cask_err"' EXIT

if ! all_formula_updates="$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --formula --verbose 2>"${formula_err}")"; then
	echo "Error: Homebrew could not check formula updates:" >&2
	cat "${formula_err}" >&2
	exit 1
fi
if ! all_cask_updates="$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --cask --greedy-auto-updates --verbose 2>"${cask_err}")"; then
	echo "Error: Homebrew could not check cask updates:" >&2
	cat "${cask_err}" >&2
	exit 1
fi

if [[ -s ${formula_err} || -s ${cask_err} ]]; then
	cat "${formula_err}" "${cask_err}" >&2
fi

is_managed() {
	local candidate="$1"
	shift
	local item
	for item in "$@"; do
		if [[ ${candidate} == "${item}" || ${candidate} == "${item##*/}" ]]; then
			return 0
		fi
	done
	return 1
}

filter_updates() {
	local updates="$1"
	shift
	local line name
	while IFS= read -r line; do
		[[ -z ${line} ]] && continue
		name="${line%% *}"
		# is_managed uses its status as a predicate; a non-match is expected.
		# shellcheck disable=SC2310
		if is_managed "${name}" "$@"; then
			echo "${line}"
		fi
	done <<<"${updates}"
	return 0
}

formula_updates="$(filter_updates "${all_formula_updates}" "${formulae[@]}")"
cask_updates="$(filter_updates "${all_cask_updates}" "${casks[@]}")"

release_overview() {
	local tool="$1"
	local info repo release

	command -v gh >/dev/null 2>&1 || return 0
	info="$(HOMEBREW_NO_AUTO_UPDATE=1 brew info --json=v2 "${tool}" 2>/dev/null || true)"
	repo="$(sed -nE 's#.*https://github\.com/([^/"]+/[^/"?#]+).*#\1#p' <<<"${info}" | head -n 1)"
	repo="${repo%.git}"
	[[ -n ${repo} ]] || return 0

	if release="$(gh release view --repo "${repo}" --json tagName,url,body --jq '
    .tagName,
    .url,
    ((.body // "")
      | split("\n")
      | map(gsub("^[[:space:]#*-]+|[[:space:]]+$"; ""))
      | map(select(length > 0))
      | .[0:4]
      | join(" — "))
  ' 2>/dev/null)"; then
		local tag url summary
		tag="$(sed -n '1p' <<<"${release}")"
		url="$(sed -n '2p' <<<"${release}")"
		summary="$(sed -n '3p' <<<"${release}")"
		echo "  Latest upstream release: ${tag} - ${url}"
		[[ -z ${summary} ]] || echo "  Overview: ${summary}"
	else
		echo "  Releases: https://github.com/${repo}/releases"
	fi
}

print_updates() {
	local heading="$1" updates="$2"
	[[ -n ${updates} ]] || return 0
	echo "${heading}"
	local line tool
	while IFS= read -r line; do
		echo "${line}"
		if [[ ${include_release_notes} == true ]]; then
			tool="${line%% *}"
			release_overview "${tool}"
		fi
	done <<<"${updates}"
}

echo "Brewfile tool update report"
generated_at="$(date '+%Y-%m-%d %H:%M %Z')"
echo "Generated: ${generated_at}"
echo

if [[ -z "${formula_updates}${cask_updates}" ]]; then
	echo "All installed tools declared in Brewfile are up to date."
	exit 0
fi

print_updates "Formulae" "${formula_updates}"
if [[ -n ${formula_updates} && -n ${cask_updates} ]]; then
	echo
fi
print_updates "Casks" "${cask_updates}"

echo
echo "Upgrade deliberately with: brew upgrade <tool>"
echo "Then refresh the inventory with: ./scripts/snapshot-tool-versions.sh"
