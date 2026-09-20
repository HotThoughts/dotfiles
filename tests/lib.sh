# Sourced by *.test.sh; consumers below read ${repo_root} after sourcing.
# shellcheck shell=bash disable=SC2034
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${test_dir}/.." && pwd)"

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

assert_equal() {
	local expected="$1" actual="$2"
	[[ ${actual} == "${expected}" ]] || fail "expected '${expected}', got '${actual}'"
}

assert_file_contains() {
	local path="$1" expected="$2"
	grep -Fq -- "${expected}" "${path}" || fail "${path} does not contain '${expected}'"
}

pass() {
	echo "PASS: $*"
}
