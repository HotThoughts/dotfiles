if type -q exa
  function ll
    exa -l -g --icons $argv
  end
end
