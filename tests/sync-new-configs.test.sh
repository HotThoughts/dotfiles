#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT
mkdir -p "${test_root}/bin" "${test_root}/home" "${test_root}/src" "${test_root}/cache" "${test_root}/state"

# See tests/sync-managed-files.test.sh for why the config file has its own
# directory: chezmoi protects the config file's directory when adding.
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

# `chezmoi unmanaged` only reports files inside directories chezmoi already
# manages, so seed the tool directories the way a tracked tool's config
# directory looks, then drop the unmanaged files a new tool would leave behind.
mkdir -p "${src}/dot_config/newtool/nested" "${src}/dot_local/bin"
printf 'seed=1\n' >"${src}/dot_seed"
chezmoi apply

mkdir -p "${home}/.config/newtool/nested" "${home}/.local/bin"
printf '[tool]\n1\n' >"${home}/.config/newtool/config.toml"
printf 'deep: 1\n' >"${home}/.config/newtool/nested/deep.yaml"
printf 'cache\n' >"${home}/.config/newtool/cache.db"
printf '{"token":"x"}\n' >"${home}/.config/newtool/token.json"
printf 'notes\n' >"${home}/.config/newtool/notes.txt"
printf '#!/bin/sh\necho hi\n' >"${home}/.local/bin/newscript.sh"
chmod 755 "${home}/.local/bin/newscript.sh"

audit="${test_root}/audit.txt"
bash "${repo_root}/scripts/sync-new-configs.sh" >"${audit}"

assert_file_contains "${audit}" "candidate  ~/.config/newtool/config.toml"
assert_file_contains "${audit}" "candidate  ~/.config/newtool/nested/deep.yaml"
assert_file_contains "${audit}" "candidate  ~/.local/bin/newscript.sh"
if grep -Fq -e 'cache.db' -e 'notes.txt' "${audit}"; then
	fail "audit listed a filtered file"
fi
assert_file_contains "${audit}" "Sensitive (never auto-added):"
assert_file_contains "${audit}" "  ~/.config/newtool/token.json"

bash "${repo_root}/scripts/sync-new-configs.sh" --write >"${test_root}/write.txt"

assert_equal "$(cat "${home}/.config/newtool/config.toml")" "$(cat "${src}/dot_config/newtool/config.toml")"
assert_equal "$(cat "${home}/.config/newtool/nested/deep.yaml")" "$(cat "${src}/dot_config/newtool/nested/deep.yaml")"
assert_equal "$(cat "${home}/.local/bin/newscript.sh")" "$(cat "${src}/dot_local/bin/executable_newscript.sh")"

managed="$(chezmoi managed --path-style absolute)"
for target in \
	"${home}/.config/newtool/config.toml" \
	"${home}/.config/newtool/nested/deep.yaml" \
	"${home}/.local/bin/newscript.sh"; do
	grep -Fxq -- "${target}" <<<"${managed}" || fail "${target} is not managed after --write"
done

for unexpected in cache.db token.json notes.txt; do
	if [[ -e "${src}/dot_config/newtool/${unexpected}" ]]; then
		fail "${unexpected} was added to the source state"
	fi
done

bash "${repo_root}/scripts/sync-new-configs.sh" --path "${home}/.config/newtool/notes.txt" --write >"${test_root}/path-write.txt"
[[ -e "${src}/dot_config/newtool/notes.txt" ]] || fail "--path did not add notes.txt"
assert_equal "$(cat "${home}/.config/newtool/notes.txt")" "$(cat "${src}/dot_config/newtool/notes.txt")"

pass "sync-new-configs lists candidates and adds only the reviewed set"
