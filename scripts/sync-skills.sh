#!/usr/bin/env bash
#
# Sync Copilot CLI skills to skills.yaml
# This script extracts currently installed skills from 'npx skills list'
# and updates the skills.yaml manifest file.

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
SKILLS_YAML="$REPO_ROOT/skills.yaml"

echo -e "${BLUE}=== Syncing Installed Skills to skills.yaml ===${NC}\n"

# Get list of installed skills
echo -e "${YELLOW}Reading installed skills from 'npx skills list'...${NC}"

# Create temp file for skills
temp_file=$(mktemp)
trap "rm -f $temp_file" EXIT

# Extract skills (strip ANSI codes and parse)
npx skills list -g 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -E "^[[:space:]]+[a-z0-9_-]+ ~" | awk '{print $1}' | sort -u > "$temp_file"

# Count skills
skill_count=$(wc -l < "$temp_file" | xargs)

if [[ "$skill_count" -eq 0 ]]; then
    echo -e "${YELLOW}No skills found${NC}"
    echo "Run 'npx skills add <package>' to install skills first"
    exit 0
fi

echo -e "${GREEN}Found $skill_count installed skills${NC}\n"

# Backup existing skills.yaml if it exists
if [[ -f "$SKILLS_YAML" ]]; then
    backup_file="${SKILLS_YAML}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SKILLS_YAML" "$backup_file"
    echo -e "${BLUE}Backed up existing skills.yaml to: $(basename "$backup_file")${NC}"
fi

# Generate new skills.yaml
echo -e "${BLUE}Generating skills.yaml...${NC}"

cat > "$SKILLS_YAML" << 'EOF'
# Copilot CLI Skills Manifest
# Managed by sync-skills.sh
#
# This file tracks all installed Copilot CLI skills.
# Skills are automatically extracted from 'npx skills list -g'.
#
# To install skills from this manifest: ./scripts/install-skills.sh
# To update this file: ./scripts/sync-skills.sh (or @update-dotfiles)

EOF

echo "skills:" >> "$SKILLS_YAML"

# Generate YAML entries (simple list of skill names)
while read -r skill_name; do
    echo "  - $skill_name" >> "$SKILLS_YAML"
done < "$temp_file"

echo -e "${GREEN}✓ Successfully updated skills.yaml with $skill_count skills${NC}\n"

# Display the skills
echo -e "${BLUE}Skills in manifest:${NC}"
grep "^  - " "$SKILLS_YAML" | sed 's/^/  /'

echo -e "\n${GREEN}Done! Skills synced from installed skills.${NC}"
echo -e "Location: ${SKILLS_YAML}"
