#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for test_file in "${test_dir}"/*.test.sh; do
	bash "${test_file}"
done
