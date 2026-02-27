#!/usr/bin/env bash
#
# Sync Brewfile from atuin history
# This script extracts brew install/uninstall commands from atuin history
# and updates the Brewfile to reflect what should be installed.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine script directory and repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BREWFILE="$REPO_ROOT/Brewfile"

# Check if atuin is installed
if ! command -v atuin &> /dev/null; then
    echo -e "${RED}Error: atuin is not installed${NC}"
    echo "Install it with: brew install atuin"
    exit 1
fi

echo -e "${BLUE}=== Analyzing Brew Commands from Atuin History ===${NC}\n"

# Create temp files
installs=$(mktemp)
uninstalls=$(mktemp)
trap "rm -f $installs $uninstalls" EXIT

# Extract successful brew install commands
echo -e "${YELLOW}Extracting brew install commands...${NC}"
atuin search --exit 0 "brew install" 2>&1 | grep "brew install" | awk -F'\t' '{print $2}' | while read -r line; do
    # Extract package name(s) from command
    # Remove brew install and flags
    packages=$(echo "$line" | sed 's/brew install //' | sed 's/--[a-z-]*//g' | sed 's/  */ /g')
    echo "$packages" >> "$installs"
done

# Extract successful brew uninstall commands  
echo -e "${YELLOW}Extracting brew uninstall commands...${NC}"
atuin search --exit 0 "brew uninstall" 2>&1 | grep "brew uninstall" | awk -F'\t' '{print $2}' | while read -r line; do
    # Extract package name(s) from command
    packages=$(echo "$line" | sed 's/brew uninstall //' | sed 's/--[a-z-]*//g' | sed 's/-f$//' | sed 's/  */ /g')
    echo "$packages" >> "$uninstalls"
done

# Show statistics
install_count=$(sort -u "$installs" | wc -l | xargs)
uninstall_count=$(sort -u "$uninstalls" | wc -l | xargs)

echo -e "${GREEN}Found ${install_count} unique packages installed${NC}"
echo -e "${YELLOW}Found ${uninstall_count} unique packages uninstalled${NC}\n"

# Show what would be added
echo -e "${BLUE}Packages in history but not in Brewfile:${NC}"
while read -r pkg; do
    if ! grep -q "\"$pkg\"" "$BREWFILE" && ! grep -q " $pkg$" "$BREWFILE" && ! grep -q "/$pkg\"" "$BREWFILE"; then
        echo -e "  ${GREEN}+ $pkg${NC}"
    fi
done < <(sort -u "$installs" | grep -v "^$")

echo -e "\n${BLUE}Packages uninstalled but still in Brewfile:${NC}"
while read -r pkg; do
    if grep -q "\"$pkg\"" "$BREWFILE" || grep -q " $pkg$" "$BREWFILE" || grep -q "/$pkg\"" "$BREWFILE"; then
        echo -e "  ${RED}- $pkg${NC}"
    fi
done < <(sort -u "$uninstalls" | grep -v "^$")

echo -e "\n${YELLOW}Note: This is a dry-run analysis.${NC}"
echo -e "${YELLOW}Review the changes above and manually update your Brewfile.${NC}"
echo -e "\nBrewfile location: ${BREWFILE}"
