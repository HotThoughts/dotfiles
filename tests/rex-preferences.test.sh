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

# Stub a command that logs every argument, including spaces within a value.
capture_stub() {
	local name="$1" log="$2"
	printf '#!/usr/bin/env bash\nprintf "<%%s>" "$@" >>%q\nprintf "\\n" >>%q\n' \
		"${log}" "${log}" >"${test_root}/bin/${name}"
	chmod +x "${test_root}/bin/${name}"
}

# Stubs keep applying away from the real defaults domain, Rex server, and app.
capture="${test_root}/defaults.log"
rex_capture="${test_root}/rex.log"
capture_stub defaults "${capture}"
capture_stub rex "${rex_capture}"
ln -s "$(command -v false)" "${test_root}/bin/pgrep"
real_path="${PATH}"
export PATH="${test_root}/bin:${PATH}"

target="${test_root}/home/.config/rex"
template="${test_root}/source/dot_config/rex/run_onchange_after_preferences.sh.tmpl"

apply_darwin() {
	run_chezmoi apply --override-data '{"chezmoi":{"os":"darwin"}}' "$@" "${target}" >/dev/null
}

assert_reloaded() {
	assert_file_contains "${rex_capture}" "<config><check><${target}/init.lua>"
	assert_file_contains "${rex_capture}" '<--autostart=false><config><reload>'
}

# Applying the Rex directory creates it, deploys init.lua, and runs its scripts.
apply_darwin --parent-dirs
cmp "${repo_root}/dot_config/rex/init.lua" "${target}/init.lua"
assert_file_contains "${capture}" '<write><com.superlogical.rex><Workspace.terminalFontName><-string><Operator Mono>'
assert_file_contains "${capture}" '<write><com.superlogical.rex><Workspace.terminalFontPointSize><-float><14>'
assert_file_contains "${capture}" '<write><com.superlogical.rex><Workspace.tabIconTintMode><-string><off>'
assert_file_contains "${capture}" '<write><com.superlogical.rex><rex.server.web-client-origin-patterns><-array><https://rex.superlogical.com>'
if grep -Eq 'lastFocusedSession|programActivitySeen|NSWindow|RexSync|cached-route|<import>|<delete>' "${capture}"; then
	fail "Rex preferences script touches runtime state or replaces the domain"
fi
assert_reloaded

# Nothing re-runs when nothing changed.
first_defaults="$(cat "${capture}")"
first_rex="$(cat "${rex_capture}")"
apply_darwin
assert_equal "${first_defaults}" "$(cat "${capture}")"
assert_equal "${first_rex}" "$(cat "${rex_capture}")"

# Editing init.lua re-runs only the reload script.
: >"${rex_capture}"
echo '-- changed' >>"${test_root}/source/dot_config/rex/init.lua"
apply_darwin
assert_reloaded
assert_equal "${first_defaults}" "$(cat "${capture}")"

# Validate the real config with the installed Rex, when there is one.
if PATH="${real_path}" command -v rex >/dev/null 2>&1; then
	PATH="${real_path}" rex config check "${repo_root}/dot_config/rex/init.lua" >/dev/null ||
		fail "rex config check rejects dot_config/rex/init.lua"
fi

# The macOS preferences script must render to nothing on other platforms.
linux_script="$(run_chezmoi execute-template --override-data '{"chezmoi":{"os":"linux"}}' --file "${template}")"
assert_equal "" "${linux_script}"

pass "Rex config reloads and GUI preferences restore through chezmoi without replacing runtime state"
