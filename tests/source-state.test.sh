#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT
mkdir -p "${test_root}/cache" "${test_root}/home"
config="${test_root}/chezmoi.toml"

HOME="${test_root}/home" chezmoi --source "${repo_root}" --cache "${test_root}/cache" \
	execute-template --init \
	--promptString name="Test User" \
	--promptString email="test@example.com" \
	--promptString github="tester" \
	--promptString signingkey="ABC123" \
	--promptString editor="nvim" \
	<"${repo_root}/.chezmoi.toml.tmpl" >"${config}"

managed="$(HOME="${test_root}/home" chezmoi --config "${config}" \
	--source "${repo_root}" --cache "${test_root}/cache" \
	--refresh-externals=never managed)"

for target in \
	.gitignore \
	.codex/AGENTS.md \
	.claude/CLAUDE.md \
	.config/opencode/AGENTS.md \
	.config/nvim/lazy-lock.json \
	.config/ghostty/shaders/cursor_blaze.glsl; do
	grep -Fxq -- "${target}" <<<"${managed}" || fail "${target} is not managed"
done

for repo_only in Brewfile README.md AGENTS.md skills.yaml scripts tests .lycheeignore .typos.toml _run_onchange_before_10-install-packages.sh; do
	if grep -Fxq -- "${repo_only}" <<<"${managed}"; then
		fail "repository-only path ${repo_only} would be copied into HOME"
	fi
done

for template in \
	run_once_before_00-install-homebrew.sh.tmpl \
	run_onchange_after_20-install-fish-plugins.sh.tmpl; do
	HOME="${test_root}/home" chezmoi --config "${config}" --source "${repo_root}" \
		--cache "${test_root}/cache" execute-template --file "${repo_root}/${template}" \
		>"${test_root}/${template%.tmpl}"
	bash -n "${test_root}/${template%.tmpl}"
done

jq empty "${repo_root}/.vscode/mcp.json" "${repo_root}/dot_config/nvim/lazy-lock.json"

pass "chezmoi source state renders and excludes repository-only files"
