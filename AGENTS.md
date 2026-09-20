# Repository guidance

- This is a chezmoi source repository. Edit source-state paths here, not the
  rendered files in `$HOME`.
- Never run `chezmoi apply`, `chezmoi update`, or `chezmoi purge` unless the
  user explicitly asks. Prefer `chezmoi diff`, template rendering, and tests.
- Keep repository-only files listed in `.chezmoiignore` so they are not copied
  into `$HOME`.
- Update `Brewfile` and `Brewfile.versions` together. Package installation must
  not implicitly upgrade already-installed formulae or casks.
- Never commit rendered secrets. Secret-backed files must remain templates that
  read from the system keychain or another external secret store.
- Keep dependency revisions explicit and update them deliberately with their
  checksums or lockfiles.
- Preserve unrelated user changes and keep commits free of agent attribution.
