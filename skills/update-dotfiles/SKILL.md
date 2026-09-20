---
name: update-dotfiles
description: Audit and deliberately refresh the Homebrew, tool-version, and agent-skill manifests in this chezmoi repository. Use when reconciling installed tools with source state or preparing reviewed dependency updates.
---

# Update dotfile manifests

Work from the chezmoi source repository and keep updates reviewable.

## Safety rules

- Do not run `chezmoi apply`, install packages, or install skills unless the user
  explicitly requests that separate action.
- Start with read-only audits. Only use a script's write mode when the user asks
  to update the corresponding manifest.
- Preserve manual Brewfile choices; history is evidence, not authority.
- Review every generated diff and retain immutable refs or recorded versions.

## Audit workflow

1. Inspect `git status` and the current manifests.
2. Run `./scripts/sync-brewfile.sh` to compare successful Homebrew history with
   `Brewfile`; it reports candidates without editing the file.
3. Run `./scripts/sync-skills.sh` to compare pinned skill repositories with
   upstream HEAD; it reports available changes without editing the manifest.
4. Run `./scripts/snapshot-tool-versions.sh --stdout` and compare the result with
   `Brewfile.versions`.
5. Summarize proposed additions, removals, and version changes before writing.

## Write workflow

- Refresh the installed-version inventory with
  `./scripts/snapshot-tool-versions.sh`.
- Refresh skill refs only with `./scripts/sync-skills.sh --write`, then inspect
  the diff. `./scripts/install-skills.sh` is a separate, state-changing step.
- Edit `Brewfile` manually after reviewing the audit rather than automatically
  dumping all installed packages.
- Run repository tests and `prek` in a disposable copy if hooks may rewrite
  files.
