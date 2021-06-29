set -gx PATH /usr/local/bin $PATH
fish_vi_key_bindings

if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end


# Aliases
alias dotfiles "/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias fishconf "vim ~.config/fish/config.fish"
alias vimrc "vim ~/.vimrc"
alias tmux.conf "vim ~/.tmux.conf"
alias ohmyzsh "vim ~/.oh-my-zsh"
alias sshconfig "vim ~/.ssh/config"
alias pip "pip3"
alias python "python3"
alias update_comet_ml "pip3 install comet_ml --upgrade --upgrade-strategy eager"
alias code "code-insiders"
 

# BasicTeX
alias texupdate "sudo tlmgr update --self && sudo tlmgr update --all"
alias texinstall "sudo tlmgr install"
set -gx PATH "/usr/local/sbin:$PATH"
set -gx MANPATH "/Library/TeX/Distributions/.DefaultTeX/Contents/Man:$MANPATH"

# qt
set -gx PATH "/usr/local/opt/qt/bin:$PATH"
set -gx LDFLAGS "-L/usr/local/opt/qt/lib"
set -gx CPPFLAGS "-I/usr/local/opt/qt/include"
set -gx PKG_CONFIG_PATH "/usr/local/opt/qt/lib/pkgconfig"

# ruby
set -gx PATH "/usr/local/opt/ruby/bin:$PATH"
set -gx LDFLAGS "/usr/local/opt/ruby/lib"
set -gx CPPFLAGS "/usr/local/opt/ruby/include"
set -gx PKG_CONFIG_PATH "/usr/local/opt/ruby/lib/pkgconfig"
set -gx PATH "$HOME/.gem/ruby/2.7.2/bin:$PATH"

# Poetry
set -gx PATH "$HOME/.poetry/bin:$PATH"

