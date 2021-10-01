if type -q exa
  function ls
    exa --icons $argv
  end
end
