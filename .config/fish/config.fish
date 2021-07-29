set -gx PATH /usr/local/bin $PATH
set -gx EXA_ICON_SPACING 2

function notify
  set -l job (jobs -l -g)
    or begin; echo "There are no jobs" >&2; return 1; end

    function _notify_job_$job --on-job-exit $job --inherit-variable job
      echo -n \a # beep
      functions -e _notify_job_$job
    end
end

# BasicTex
set PATH /usr/local/sbin $PATH
set MANPATH /Library/TeX/Distributions/.DefaultTeX/Contents/Man $MANPATH

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
