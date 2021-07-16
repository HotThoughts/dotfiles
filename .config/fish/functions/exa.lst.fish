if type -q exa
  function lst
    exa --icons --tree --level $argv
  end
end
