---
name: update-dotfiles
description: Audit and deliberately refresh this chezmoi repository — destination drift, unmanaged config files, and the Homebrew, tool-version, and agent-skill manifests. Use when reconciling local config or installed tools with source state, or preparing reviewed dependency updates.
---

# Update dotfile manifests

Work from the chezmoi source repository and keep updates reviewable.

## Safety rules

- Do not run `chezmoi apply`, install packages, or install skills unless the
  user explicitly requests that separate action.
- Start with read-only audits. Only use a script's write mode when the user asks
  to update the corresponding manifest.
- Preserve manual Brewfile choices; history is evidence, not authority.
- Review every generated diff and retain immutable refs or recorded versions.

## Audit workflow

1. Inspect `git status` and the current manifests.
2. Run `./scripts/sync-managed-files.sh` to list managed files whose `$HOME`
   copy drifted from source state; it reports without editing anything.
3. Run `./scripts/sync-new-configs.sh` to list unmanaged config files that may
   belong in source state; it reports without editing anything.
4. Run `./scripts/sync-brewfile.sh` to compare successful Homebrew history with
   `Brewfile`; it reports candidates without editing the file.
5. Run `./scripts/sync-skills.sh` to compare pinned skill repositories with
   upstream HEAD; it reports available changes without editing the manifest.
6. Run `./scripts/snapshot-tool-versions.sh --stdout` and compare the result
   with `Brewfile.versions`.
7. Summarize proposed additions, removals, and version changes before writing.

## Write workflow

- Re-add reviewed drift with `./scripts/sync-managed-files.sh --write`, and add
  reviewed config files with `./scripts/sync-new-configs.sh --write`.
- Preview any write with the underlying `chezmoi re-add --dry-run` or
  `chezmoi add --dry-run`, and diff the source against the target, before
  committing to it.
- Refresh the installed-version inventory with
  `./scripts/snapshot-tool-versions.sh`.
- Refresh skill refs only with `./scripts/sync-skills.sh --write`, then inspect
  the diff. `./scripts/install-skills.sh` is a separate, state-changing step.
- Edit `Brewfile` manually after reviewing the audit rather than automatically
  dumping all installed packages.
- Run repository tests and `prek` in a disposable copy if hooks may rewrite
  files.

## Destination drift (re-add)

- Run `./scripts/sync-managed-files.sh` for the audit. It reads
  `chezmoi managed`, `chezmoi source-path`, and `chezmoi state dump`, never
  renders a template, and prints one line per out-of-sync managed file:
  `re-add` (destination changed, source unchanged), `conflict` (both changed),
  `unknown` (no state record), `missing` (absent from `$HOME`), `apply` (source
  changed), and `stale` (already identical to source). Every `conflict` also
  prints its unified diff.
- Re-add only clean drift with `./scripts/sync-managed-files.sh --write`.
- Use `--force` only after reading the printed conflict diff: it extends the
  re-add to the `conflict` and `unknown` sets.
- Verify with `jj diff` and `bash tests/run.sh`.
- The single-file equivalent is `chezmoi re-add <path>`. Never re-add an
  `apply` entry: its source changed, so diff the source and target first.

## Unmanaged config files (add)

- Run `./scripts/sync-new-configs.sh` for the audit. It lists candidate files
  under `~/.config` and `~/.local/bin` that chezmoi does not manage, reports
  credential-looking files under `Sensitive (never auto-added):`, and counts
  everything it filtered out.
- `chezmoi unmanaged` only reports files inside directories chezmoi already
  manages, so a brand-new tool directory is not enumerated: list it explicitly
  with `--path PATH` (or add one file there by hand first).
- Add filtered or out-of-scope files explicitly with `--path PATH`
  (extensionless scripts, `.glsl`, `.md`, or anything in a new directory).
- `./scripts/sync-new-configs.sh --write` runs `chezmoi add --secrets=error` on
  the reviewed set in one call. `--secrets=error` is a best-effort guard, not a
  substitute for review, and it never overrides the sensitive-name protection:
  sensitive paths stay `--path`-only.
- Anything with a secret must be added as a template
  (`chezmoi add --template`) whose content reads from the keychain or another
  external store, per `AGENTS.md` — never add the rendered file.
- Stop tracking a file with `chezmoi forget --force <path>`; bare `forget`
  prompts on a TTY.

## Known local caveat

- `chezmoi status`, `chezmoi diff`, `chezmoi apply`, and `chezmoi update`
  currently abort because `dot_config/zed/private_settings.json.tmpl` calls
  `keyring "chezmoi-linear" "api_key"` and `chezmoi-github`/`pat`, and those
  items are not in the login keychain. Prefer the two sync scripts: they read
  the source state and the persistent state directly, so they never render a
  template. `chezmoi managed`, `chezmoi source-path`, `chezmoi state dump`, and
  `chezmoi unmanaged` are unaffected.
- Update this skill in the same commit whenever a documented step turns out to
  be wrong.
