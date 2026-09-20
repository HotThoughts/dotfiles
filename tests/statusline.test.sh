#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT
mkdir -p "${test_root}/bin" "${test_root}/home"

cat >"${test_root}/bin/cship" <<'EOF'
#!/bin/sh
cat
EOF
chmod +x "${test_root}/bin/cship"

input='{"model":{"display_name":"Test"},"rate_limits":{"five_hour":{"used_percentage":12}}}'
output="$(printf '%s' "${input}" | HOME="${test_root}/home" PATH="${test_root}/bin:${PATH}" \
	"${repo_root}/dot_local/bin/executable_claude-statusline-wrapper.sh")"

assert_equal "${input}" "${output}"
cache="${test_root}/home/.cache/claude-code/rate_limits.json"
[[ -f ${cache} ]] || fail "statusline wrapper did not create the rate-limit cache"
assert_file_contains "${cache}" '"used_percentage":12'

pass "statusline wrapper forwards input and caches rate limits"
