function gswf -d "git switch"
  gsw $(git branch --format='%(refname:short)' | fzf)
end

