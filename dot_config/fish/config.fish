# =============================================================================
# Fish Shell Configuration
# =============================================================================

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
# Use fish_add_path (universal by default) for proper PATH management

# Local binaries (highest priority)
fish_add_path $HOME/.local/bin

# Development tools
fish_add_path $HOME/go/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.claude/local

# Kubernetes tools
fish_add_path $HOME/.krew/bin
fish_add_path $HOME/.linkerd2/bin

# Ruby
fish_add_path /usr/local/opt/ruby/bin
fish_add_path $HOME/.gem/ruby/2.7.2/bin

# Qt
fish_add_path /usr/local/opt/qt/bin

# TeX
fish_add_path /Library/TeX/texbin

# -----------------------------------------------------------------------------
# Environment Variables (Universal - persist across sessions)
# -----------------------------------------------------------------------------

# GPG
set -Ux GPG_TTY (tty)

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

# Build flags (universal for consistent build environment)
set -Ux LDFLAGS -L/usr/local/opt/qt/lib -L/usr/local/opt/ruby/lib
set -Ux CPPFLAGS -I/usr/local/opt/qt/include -I/usr/local/opt/ruby/include
set -Ux PKG_CONFIG_PATH /usr/local/opt/qt/lib/pkgconfig:/usr/local/opt/ruby/lib/pkgconfig

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
atuin init fish | sed 's/-k up/up/' | source

# Starship (prompt)
starship init fish | source

# Zoxide (directory jumping)
zoxide init fish | source

# AWS Assume (via Homebrew)
alias assume="source (brew --prefix)/bin/assume.fish"
