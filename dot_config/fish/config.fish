# =============================================================================
# Fish Shell Configuration
# =============================================================================

# Prefer native Homebrew when it is available.
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv fish)
end

if not set -q HOMEBREW_PREFIX
    set -gx HOMEBREW_PREFIX /opt/homebrew
end

# -----------------------------------------------------------------------------
# Abbreviations
# -----------------------------------------------------------------------------
abbr -a -- k kubectl
abbr -a -- kx 'kubie ctx'
abbr -a -- kns 'kubie ns'
abbr -a -- e exit
abbr -a -- ls 'eza --icons'
abbr -a -- fu 'fisher update'
abbr -a -- c clear
abbr -a -- n nvim
abbr -a -- cu 'chezmoi update'

# -----------------------------------------------------------------------------
# PATH Management
# -----------------------------------------------------------------------------
# Use session-global paths so Intel leftovers do not get persisted in fish_user_paths.

# Local binaries (highest priority)
fish_add_path -g $HOME/.local/bin

# Development tools
fish_add_path -g $HOME/go/bin
fish_add_path -g $HOME/.cargo/bin
fish_add_path -g $HOME/.claude/local
fish_add_path -g $HOME/.pyenv/bin
fish_add_path -g $HOME/.fig/bin

# Kubernetes tools
fish_add_path -g $HOME/.krew/bin
fish_add_path -g $HOME/.linkerd2/bin

# Ruby
if test -d "$HOMEBREW_PREFIX/opt/ruby/bin"
    fish_add_path -g "$HOMEBREW_PREFIX/opt/ruby/bin"
end
fish_add_path -g $HOME/.gem/ruby/2.7.2/bin

# Qt
if test -d "$HOMEBREW_PREFIX/opt/qt/bin"
    fish_add_path -g "$HOMEBREW_PREFIX/opt/qt/bin"
end

# TeX
fish_add_path -g /Library/TeX/texbin

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------

# GPG
set -gx GPG_TTY (tty)

# Editor
set -Ux EDITOR nvim
set -Ux KUBE_EDITOR nvim

# k9s
set -Ux K9S_CONFIG_DIR $HOME/.config/k9s

# Node Version Manager
set -Ux NVM_DIR $HOME/.nvm

# fzf configuration
set -Ux FZF_DEFAULT_OPTS "--multi --border --cycle --reverse --extended --height 80%"
set -Ux FZF_DEFAULT_COMMAND "fd --type f"
set -Ux FORGIT_FZF_DEFAULT_OPTS "--exact --height 80%"

# skim (fzf alternative in Rust)
set -Ux SKIM_DEFAULT_OPTIONS "--multi --border --cycle --reverse --extended --height 80%"

# eza configuration
set -Ux EZA_STANDARD_OPTIONS --icons

# Build flags for brew-managed toolchains
set -e LDFLAGS
set -e CPPFLAGS
set -e PKG_CONFIG_PATH
set -l build_ldflags
set -l build_cppflags
set -l build_pkg_config

if test -d "$HOMEBREW_PREFIX/opt/qt/lib"
    set build_ldflags $build_ldflags "-L$HOMEBREW_PREFIX/opt/qt/lib"
    set build_cppflags $build_cppflags "-I$HOMEBREW_PREFIX/opt/qt/include"
    set build_pkg_config $build_pkg_config "$HOMEBREW_PREFIX/opt/qt/lib/pkgconfig"
end

if test -d "$HOMEBREW_PREFIX/opt/ruby/lib"
    set build_ldflags $build_ldflags "-L$HOMEBREW_PREFIX/opt/ruby/lib"
    set build_cppflags $build_cppflags "-I$HOMEBREW_PREFIX/opt/ruby/include"
    set build_pkg_config $build_pkg_config "$HOMEBREW_PREFIX/opt/ruby/lib/pkgconfig"
end

if test (count $build_ldflags) -gt 0
    set -gx LDFLAGS $build_ldflags
end

if test (count $build_cppflags) -gt 0
    set -gx CPPFLAGS $build_cppflags
end

if test (count $build_pkg_config) -gt 0
    set -gx PKG_CONFIG_PATH $build_pkg_config
end

# -----------------------------------------------------------------------------
# Plugin Configuration (Global - session-specific)
# -----------------------------------------------------------------------------

# fzf.fish plugin configuration
set -g fzf_preview_dir_cmd "eza --all --icons --color=always"
set -g fzf_history_opts "--with-nth=4.."

# -----------------------------------------------------------------------------
# Fish UI Configuration (Universal - persist across sessions)
# -----------------------------------------------------------------------------

# Cursor styles
set -U fish_cursor_default block
set -U fish_cursor_insert line
set -U fish_cursor_replace_one underscore
set -U fish_cursor_visual block

# TokyoNight Color Palette
set -l foreground c8d3f5
set -l selection 3654a7
set -l comment 7a88cf
set -l red ff757f
set -l orange ff966c
set -l yellow ffc777
set -l green c3e88d
set -l purple fca7ea
set -l cyan 86e1fc
set -l pink c099ff

# Syntax Highlighting Colors
set -U fish_color_normal $foreground
set -U fish_color_command $cyan
set -U fish_color_keyword $pink
set -U fish_color_quote $yellow
set -U fish_color_redirection $foreground
set -U fish_color_end $orange
set -U fish_color_error $red
set -U fish_color_param $purple
set -U fish_color_comment $comment
set -U fish_color_selection --background=$selection
set -U fish_color_search_match --background=$selection
set -U fish_color_operator $green
set -U fish_color_escape $pink
set -U fish_color_autosuggestion $comment

# Completion Pager Colors
set -U fish_pager_color_progress $comment
set -U fish_pager_color_prefix $cyan
set -U fish_pager_color_completion $foreground
set -U fish_pager_color_description $comment
set -U fish_pager_color_selected_background --background=$selection

# -----------------------------------------------------------------------------
# Tool Initialization
# -----------------------------------------------------------------------------

# Atuin (command history)
if command -q atuin
    atuin init fish | sed 's/-k up/up/' | source
end

# Starship (prompt)
if command -q starship
    starship init fish | source
end

# Zoxide (directory jumping)
if command -q zoxide
    zoxide init fish | source
end

# AWS Assume (via Homebrew)
if command -q brew
    alias assume="source (brew --prefix)/bin/assume.fish"
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
