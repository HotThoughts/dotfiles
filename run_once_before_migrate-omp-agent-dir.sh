#!/bin/sh
# Relocate omp's agent directory from ~/.omp/agent to ~/.config/omp, the
# location PI_CODING_AGENT_DIR points at (see dot_zshrc,
# dot_config/fish/config.fish, and dot_bashrc.tmpl).
#
# A single mv is atomic on one filesystem and carries the auth store, session
# history, and caches along with the config, so an existing login survives.
# The guard makes this a no-op on an already-migrated machine and on a machine
# with nothing to move.

set -eu

agent_dir="$HOME/.omp/agent"
config_dir="$HOME/.config/omp"

if [ -e "$config_dir" ] || [ ! -d "$agent_dir" ]; then
	exit 0
fi

mkdir -p "$(dirname "$config_dir")"
mv "$agent_dir" "$config_dir"
