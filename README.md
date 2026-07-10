# Dotfiles

macOS dotfiles managed with [chezmoi](https://www.chezmoi.io).

This repository bootstraps a development-focused terminal environment: Fish,
Starship, Neovim/LazyVim, Ghostty, Herdr, Jujutsu, Kubernetes tooling, and a
curated Homebrew bundle.

## Highlights

- **Shell**: [Fish](https://fishshell.com/) with Fisher-managed plugins
- **Prompt**: [Starship](https://starship.rs) with
  [Jujutsu](https://martinvonz.github.io/jj/) integration
- **Editor**: [Neovim](https://neovim.io/) with
  [LazyVim](https://www.lazyvim.org/)
- **Terminal**: [Ghostty](https://github.com/ghostty-org/ghostty) and Herdr
- **Version control**: Git, [Jujutsu](https://martinvonz.github.io/jj/),
  [lazygit](https://github.com/jesseduffield/lazygit), and lazyjj
- **Theme**: Tokyo Night across the shell, editor, and terminal surfaces
- **Navigation**: [fzf](https://github.com/junegunn/fzf),
  [zoxide](https://github.com/ajeetdsouza/zoxide), Atuin, fd, and ripgrep
- **Quality**: [Trunk](https://trunk.io/), prek, actionlint, hadolint,
  gitleaks, and trufflehog
- **macOS workflow**: AeroSpace, SketchyBar, Karabiner-Elements, and Raycast

## Quick Start

### Requirements

- macOS
- `git`
- `curl` or `wget`

### Install

```bash
git clone https://github.com/HotThoughts/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
./install.sh
```

`install.sh` bootstraps chezmoi if needed, then runs `chezmoi init --apply`
against this source directory. On macOS, the one-time setup template installs
Xcode Command Line Tools, Homebrew, packages from `Brewfile`, and Fish plugins.

## What Gets Managed

### Shell

- Fish configuration, abbreviations, paths, and environment variables
- Starship prompt configuration
- Atuin history, zoxide navigation, fzf defaults, and eza aliases
- tmux and Zellij terminal multiplexing configuration

### Editors

- Neovim/LazyVim configuration and plugins
- Zed settings, keymap, and tasks

### Terminals

- Ghostty configuration
- Herdr terminal workspace configuration
- Kitty and Alacritty configuration
- Tokyo Night-themed shell and terminal colors

### Version Control

- Git configuration template
- Jujutsu configuration, aliases, signing, and private revsets
- lazygit, lazyjj, and hunk configuration

### Kubernetes

- kubectl, kubie, helm, and k9s configuration
- k9s skins and views
- helper scripts for EKS and common Kubernetes workflows

### macOS Desktop

- AeroSpace tiling window manager configuration
- SketchyBar configuration and plugins
- Karabiner-Elements private keyboard configuration
- Raycast and related productivity apps from `Brewfile`

## Daily Usage

### Chezmoi

```bash
chezmoi diff      # Preview changes before applying them
chezmoi apply     # Apply source changes to $HOME
chezmoi edit FILE # Edit a managed file and apply it on save
chezmoi add FILE  # Add an existing local file to chezmoi
chezmoi update    # Pull the repo and apply changes
chezmoi doctor    # Check chezmoi health and environment details
```

### Local Changes

1. Edit files in `~/.local/share/chezmoi`.
2. Run `chezmoi diff`.
3. Run `chezmoi apply`.
4. Commit the change.

### Common Fish Abbreviations

| Abbreviation | Expands to       | Purpose                     |
| ------------ | ---------------- | --------------------------- |
| `k`          | `kubectl`        | Kubernetes CLI              |
| `kx`         | `kubie ctx`      | Switch Kubernetes context   |
| `kns`        | `kubie ns`       | Switch Kubernetes namespace |
| `ls`         | `eza --icons`    | Modern directory listing    |
| `n`          | `nvim`           | Open Neovim                 |
| `cu`         | `chezmoi update` | Update and apply dotfiles   |
| `fu`         | `fisher update`  | Update Fish plugins         |

## Development Workflow

```bash
trunk check   # Run linters
trunk fmt     # Format files
trunk upgrade # Update Trunk plugins
```

Prek is configured as a fast pre-commit replacement for shell scripts, Python,
Markdown, YAML, JSON, TOML, secret scanning, and related checks.

### Jujutsu Shortcuts

| Alias           | Description                                           |
| --------------- | ----------------------------------------------------- |
| `jj mine`       | List bookmarks owned by the current user              |
| `jj tug`        | Move the closest bookmark to the closest pushable rev |
| `jj rebase-all` | Rebase mutable local work onto trunk                  |
| `jj prek`       | Run prek against files changed in the current change  |
| `jj push`       | Run checks, then push                                 |
| `jj push-pr`    | Run checks, then create or update a pull request      |

Commits whose descriptions start with `wip:` or `private:` are excluded from
git push through the configured private revsets.

## Screenshots

**Shell**: Starship prompt with Jujutsu integration.

![Terminal](fig/terminal.png)

**Editor**: LazyVim configuration.

![LazyVim](fig/lazyvim.png)

**Theme**: Tokyo Night applied across VS Code, Neovim, Ghostty, Fish, and
Obsidian.

## License

Personal dotfiles. Use as inspiration.
