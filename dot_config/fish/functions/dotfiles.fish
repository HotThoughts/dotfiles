function dotfiles
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end

abbr -a dfs dotfiles
