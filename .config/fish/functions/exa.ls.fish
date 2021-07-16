if type -q exa
  function ls
    exa --tree --level=1 --icons $argv
  end
end
