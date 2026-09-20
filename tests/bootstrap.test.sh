#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT
mkdir -p "${test_root}/bin" "${test_root}/home"

cat >"${test_root}/bin/chezmoi" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" >"$TEST_CAPTURE"
EOF
chmod +x "${test_root}/bin/chezmoi"

capture="${test_root}/args"
HOME="${test_root}/home" TEST_CAPTURE="${capture}" \
	PATH="${test_root}/bin:/usr/bin:/bin" \
	sh "${repo_root}/install.sh" --promptString=name=Test

expected="$(printf 'init\n--apply\n--source=%s\n--promptString=name=Test' "${repo_root}")"
actual="$(cat "${capture}")"
assert_equal "${expected}" "${actual}"

pass "bootstrap delegates to the local source and forwards init arguments"
