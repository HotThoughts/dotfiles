# fzf.fish config
set fzf_preview_dir_cmd "exa --all --icons --color=always"
set fzf_history_opts "--with-nth=4.."
set fzf_fd_opts "--hidden --exclude=.git"
# fzf config
set -gx FZF_DEFAULT_OPTS "--multi --border --cycle --reverse --extended --height 80%"
set -gx FZF_DEFAULT_COMMAND "fd --type f"
set -gx FORGIT_FZF_DEFAULT_OPTS "--exact --height 80%"

# skim - fzf in rust
set -gx SKIM_DEFAULT_OPTIONS "--multi --border --cycle --reverse --extended --height 80%"

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

function notify
  set -l job (jobs -l -g)
    or begin; echo "There are no jobs" >&2; return 1; end

    function _notify_job_$job --on-job-exit $job --inherit-variable job
      echo -n \a # beep
      functions -e _notify_job_$job
    end
end

# Editor
set -gx EDITOR lvim

# qt
set PATH /usr/local/opt/qt/bin $PATH
set LDFLAGS "-L/usr/local/opt/qt/lib"
set CPPFLAGS "-I/usr/local/opt/qt/include"
set PKG_CONFIG_PATH "/usr/local/opt/qt/lib/pkgconfig"

# ruby
set PATH /usr/local/opt/ruby/bin $PATH
set LDFLAGS "/usr/local/opt/ruby/lib"
set CPPFLAGS "/usr/local/opt/ruby/include"
set PKG_CONFIG_PATH "/usr/local/opt/ruby/lib/pkgconfig"
set PATH $HOME/.gem/ruby/2.7.2/bin $PATH

# Poetry
set PATH $HOME/.poetry/bin $PATH
set PYENV_ROOT $HOME/.pyenv
set PYENV_VIRTUALENV_DISABLE_PROMPT 1

# LunarVim
set PATH $HOME/.local/bin $PATH

# Golang
set PATH $HOME/go/bin $PATH

# node
set -gx NVM_DIR $HOME/.nvm

# Tex
set PATH /Library/TeX/texbin/ $PATH

# Fish syntax highlighting
set -g fish_color_autosuggestion '555'  'brblack'
set -g fish_color_cancel -r
set -g fish_color_command --bold
set -g fish_color_comment red
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_end brmagenta
set -g fish_color_error brred
set -g fish_color_escape 'bryellow'  '--bold'
set -g fish_color_history_current --bold
set -g fish_color_host normal
set -g fish_color_match --background=brblue
set -g fish_color_normal normal
set -g fish_color_operator bryellow
set -g fish_color_param cyan
set -g fish_color_quote yellow
set -g fish_color_redirection brblue
set -g fish_color_search_match 'bryellow'  '--background=brblack'
set -g fish_color_selection 'white'  '--bold'  '--background=brblack'
set -g fish_color_user brgreen

# Promp
starship init fish | source

status is-login; and pyenv init --path | source
status is-interactive; and pyenv init - | source; and pyenv virtualenv-init - | source

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/hotthoughts/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
