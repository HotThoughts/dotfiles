function gcof -d "git checkout a branch"
  gco $(git branch --format='%(refname:short)' | fzf)
end

