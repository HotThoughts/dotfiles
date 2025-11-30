# Abbr
abbr -a -- k kubectl
abbr -a -- kx 'kubie ctx'
abbr -a -- kns 'kubie ns'
abbr -a -- e exit
abbr -a -- ls 'eza --icons'
abbr -a -- fu 'fisher update'
abbr -a -- e exit
abbr -a -- c clear
abbr -a -- n nvim

# eza
set -Ux EZA_STANDARD_OPTIONS --icons
set -gx GPG_TTY (tty)

# linkerd
set -gx PATH $PATH $HOME/.linkerd2/bin

# k8s
set -gx PATH $PATH $HOME/.krew/bin

# k9s
set -gx K9S_CONFIG_DIR $HOME/.config/k9s/

# fzf.fish config
set fzf_preview_dir_cmd "eza --all --icons --color=always"
set fzf_history_opts "--with-nth=4.."
set fzf_fd_opts "--hidden --exclude=.git"
# fzf config
set -gx FZF_DEFAULT_OPTS "--multi --border --cycle --reverse --extended --height 80%"
set -gx FZF_DEFAULT_COMMAND "fd --type f"
set -gx FORGIT_FZF_DEFAULT_OPTS "--exact --height 80%"

# skim - fzf in rust
set -gx SKIM_DEFAULT_OPTIONS "--multi --border --cycle --reverse --extended --height 80%"

# GPG
set -gx GPG_TTY (tty)

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

# Editor
set -gx EDITOR nvim

set XDG_CONFIG_HOME $HOME/.config

# qt3
set PATH /usr/local/opt/qt/bin $PATH
set LDFLAGS -L/usr/local/opt/qt/lib
set CPPFLAGS -I/usr/local/opt/qt/include
set PKG_CONFIG_PATH /usr/local/opt/qt/lib/pkgconfig

# ruby
set PATH /usr/local/opt/ruby/bin $PATH
set LDFLAGS /usr/local/opt/ruby/lib
set CPPFLAGS /usr/local/opt/ruby/include
set PKG_CONFIG_PATH /usr/local/opt/ruby/lib/pkgconfig
set PATH $HOME/.gem/ruby/2.7.2/bin $PATH

# Poetry
set PATH $HOME/.poetry/bin $PATH
set PYENV_ROOT $HOME/.pyenv
set PYENV_VIRTUALENV_DISABLE_PROMPT 1

# Golang
set PATH $HOME/go/bin $PATH

# node
set -gx NVM_DIR $HOME/.nvm

# Tex
set PATH /Library/TeX/texbin/ $PATH

# Cable
set PATH $HOME/.cabal/bin:/Users/hotthoughts/.ghcup/bin $PATH

# OrbStack
set PATH $HOME/.orbstack/bin $PATH

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
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
set -g fish_pager_color_selected_background --background=$selection

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/hotthoughts/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Promp
starship init fish | source
zoxide init fish | source
atuin init fish | source

# string match -q "$TERM_PROGRAM" kiro and . (kiro --locate-shell-integration-path fish)

alias claude="/Users/hotthoughts/.claude/local/claude"
fish_add_path $HOME/.local/bin
