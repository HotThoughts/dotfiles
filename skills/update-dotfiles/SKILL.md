---
name: update-dotfiles
description: Syncs dotfiles configuration from system state. Updates skills.yaml from installed skills and analyzes Brewfile against brew history. Keeps your dotfiles repo in sync with what's actually installed.
---

# Update Dotfiles

This skill maintains your dotfiles by automatically syncing configuration files with your actual system state.

## When to Use This Skill

Use this skill when:

- You've installed/uninstalled packages or skills and want to update manifests
- You're auditing what's changed since your last dotfiles commit
- You want to sync before pushing dotfiles to version control
- You're preparing a new machine setup and need current state

## What This Skill Does

### 1. Syncs Skills (skills.yaml)
- Reads currently installed skills from `npx skills list -g`
- Updates `skills.yaml` with all installed skills
- Creates timestamped backup of previous manifest

### 2. Analyzes Brewfile
- Extracts `brew install` and `brew uninstall` from atuin history
- Shows packages installed but not in Brewfile (suggests additions)
- Shows packages uninstalled but still in Brewfile (suggests removals)
- Provides dry-run analysis for manual review

## How It Works

The skill runs two sync scripts:
1. **Skills sync**: Reads actual installed skills from `npx skills list`
2. **Brewfile analysis**: Parses atuin history for brew commands (exit code 0 only)

Both operations are safe and create backups before making changes.

## Usage

Invoke this skill to sync everything:

```bash
# From Copilot CLI
@update-dotfiles
```

Or run scripts individually:

```bash
cd ~/.local/share/chezmoi

# Update skills only
./scripts/sync-skills.sh

# Analyze Brewfile only  
./scripts/sync-brewfile.sh
```

## Files Modified

- `skills.yaml` - Updated with currently installed skills
- `Brewfile` - Not modified (shows analysis for manual review)

## Example Output

### Skills Sync
```
✓ Successfully updated skills.yaml with 23 skills
  - find-skills
  - update-dotfiles
  - jj-workflow
  ...
```

### Brewfile Analysis
```
Packages in history but not in Brewfile:
  + k9s
  + copilot-cli
  + cursor

Packages uninstalled but still in Brewfile:
  - terraform
  - httpie
```

## Workflow

1. Run `@update-dotfiles` to sync state
2. Review the changes shown
3. Manually update Brewfile if needed
4. Commit and push dotfiles:
   ```bash
   cd ~/.local/share/chezmoi
   git add skills.yaml Brewfile
   git commit -m "sync: update from system state"
   git push
   ```

## Requirements

- `npx` and skills CLI
- `atuin` - For brew history analysis
- `bash` - Shell scripting
- Access to `~/.local/share/chezmoi` dotfiles repo
