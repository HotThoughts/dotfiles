#!/bin/sh
set -eu

if ! command -v chezmoi >/dev/null 2>&1; then
	bin_dir="$HOME/.local/bin"
	chezmoi="$bin_dir/chezmoi"
	if command -v curl >/dev/null 2>&1; then
		sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir"
	elif command -v wget >/dev/null 2>&1; then
		sh -c "$(wget -qO- get.chezmoi.io)" -- -b "$bin_dir"
	else
		echo "To install chezmoi, you must have curl or wget installed." >&2
		exit 1
	fi
else
	chezmoi=chezmoi
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
# Forward init flags so non-interactive callers can provide prompt values.
exec "$chezmoi" init --apply "--source=$script_dir" "$@"
