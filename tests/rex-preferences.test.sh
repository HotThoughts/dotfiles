#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT
mkdir -p "${test_root}/bin" "${test_root}/home" "${test_root}/source/dot_config"
cp -R "${repo_root}/dot_config/rex" "${test_root}/source/dot_config/rex"
touch "${test_root}/chezmoi.toml"

run_chezmoi() {
	chezmoi --config "${test_root}/chezmoi.toml" --source "${test_root}/source" \
		--destination "${test_root}/home" --cache "${test_root}/cache" \
		--persistent-state "${test_root}/state.boltdb" "$@"
}

# Capture every defaults argument, including spaces within a string value.
cat >"${test_root}/bin/defaults" <<'EOF'
#!/usr/bin/env bash
printf '<%s>' "$@" >>"${TEST_CAPTURE}"
printf '\n' >>"${TEST_CAPTURE}"
EOF
chmod +x "${test_root}/bin/defaults"

capture="${test_root}/defaults.log"
target="${test_root}/home/.config/rex"
template="${test_root}/source/dot_config/rex/run_onchange_after_preferences.sh.tmpl"

# Applying the Rex directory creates it, deploys init.lua, and runs its script.
PATH="${test_root}/bin:${PATH}" TEST_CAPTURE="${capture}" \
	run_chezmoi apply --parent-dirs --override-data '{"chezmoi":{"os":"darwin"}}' \
	"${target}" >"${test_root}/apply.log"
cmp "${repo_root}/dot_config/rex/init.lua" "${target}/init.lua"
assert_file_contains "${capture}" '<write><com.superlogical.rex><Workspace.terminalFontName><-string><Operator Mono>'
assert_file_contains "${capture}" '<write><com.superlogical.rex><Workspace.terminalFontPointSize><-float><14>'
assert_file_contains "${capture}" '<write><com.superlogical.rex><Workspace.sidebarCollapsed><-bool><false>'
assert_file_contains "${capture}" '<write><com.superlogical.rex><rex.server.web-client-origin-patterns><-array><https://rex.superlogical.com>'
if grep -Eq 'lastFocusedSession|programActivitySeen|NSWindow|RexSync|cached-route|<import>|<delete>' "${capture}"; then
	fail "Rex preferences script touches runtime state or replaces the domain"
fi

# Unchanged preferences must not be rewritten on the next apply.
first_apply="$(cat "${capture}")"
PATH="${test_root}/bin:${PATH}" TEST_CAPTURE="${capture}" \
	run_chezmoi apply --override-data '{"chezmoi":{"os":"darwin"}}' \
	"${target}" >"${test_root}/reapply.log"
assert_equal "${first_apply}" "$(cat "${capture}")"

# The macOS preferences script must render to nothing on other platforms.
linux_script="$(run_chezmoi execute-template --override-data '{"chezmoi":{"os":"linux"}}' --file "${template}")"
assert_equal "" "${linux_script}"

pass "Rex GUI preferences restore through chezmoi without replacing runtime state"
