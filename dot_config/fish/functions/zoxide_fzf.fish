function zoxide_fzf --description "Interactive zoxide directory selection with fzf"
    set -l orig_buffer (commandline)
    set -l selection (zoxide query --list | fzf --height 40% --reverse --border)

    if test $status -ne 0
        commandline $orig_buffer
        commandline -f repaint
        return 0
    end

    if test -n "$selection"
        commandline --insert "$selection"
        commandline -f repaint
    end
end

