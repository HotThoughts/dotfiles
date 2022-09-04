
function gpDf -d "delete multiple local branches"
  gbD $(git branch --format='%(refname:short)' | fzf -m)
end
