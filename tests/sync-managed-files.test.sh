#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT
mkdir -p "${test_root}/bin" "${test_root}/home" "${test_root}/src" "${test_root}/cache" "${test_root}/state"

# A wrapper that forwards to the real chezmoi against an isolated source,
# destination, and state tree, so re-add semantics are genuinely exercised.
# The config lives in its own directory: chezmoi treats the config file's
# directory as protected and would refuse to add anything under a parent that
# also contains the destination.
real_chezmoi="$(command -v chezmoi)"
cat >"${test_root}/bin/chezmoi" <<EOF
#!/bin/sh
exec "${real_chezmoi}" --source "${test_root}/src" --destination "${test_root}/home" \\
  --cache "${test_root}/cache" --config "${test_root}/state/chezmoi.toml" --config-format toml "\$@"
EOF
chmod +x "${test_root}/bin/chezmoi"

home="${test_root}/home"
src="${test_root}/src"
export HOME="${home}"
export PATH="${test_root}/bin:${PATH}"

printf 'alpha=1\n' >"${src}/dot_alpha"
printf 'beta=1\n' >"${src}/dot_beta"
printf 'gamma={{ .chezmoi.homeDir }}\n' >"${src}/dot_gamma.tmpl"
chezmoi apply

# Destination drift with an unchanged source: a clean re-add candidate.
printf 'alpha=2\n' >"${home}/.alpha"
# Both sides changed since the last apply: a conflict.
printf 'beta=2\n' >"${src}/dot_beta"
printf 'beta=3\n' >"${home}/.beta"
# A template target must never be classified or re-added.
printf 'gamma-edited\n' >"${home}/.gamma"

audit="${test_root}/audit.txt"
bash "${repo_root}/scripts/sync-managed-files.sh" >"${audit}"

assert_file_contains "${audit}" "re-add    ~/.alpha"
assert_file_contains "${audit}" "conflict  ~/.beta"
if grep -Fq -e '.gamma' -e 'dot_gamma' "${audit}"; then
	fail "audit reported the template target"
fi

bash "${repo_root}/scripts/sync-managed-files.sh" --write >"${test_root}/write.txt"
assert_equal "alpha=2" "$(cat "${src}/dot_alpha")"
assert_equal "beta=2" "$(cat "${src}/dot_beta")"
assert_equal "beta=3" "$(cat "${home}/.beta")"

bash "${repo_root}/scripts/sync-managed-files.sh" --write --force >"${test_root}/force.txt"
assert_equal "beta=3" "$(cat "${src}/dot_beta")"
assert_equal "gamma={{ .chezmoi.homeDir }}" "$(cat "${src}/dot_gamma.tmpl")"

pass "sync-managed-files re-adds clean drift and only forces conflicts on request"
