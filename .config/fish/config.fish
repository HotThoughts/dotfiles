set -gx PATH /usr/local/bin $PATH
fish_vi_key_bindings

if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end


# Aliases
alias dotfiles "/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias fishconf "vim ~/.config/fish/config.fish"
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
set PATH /usr/local/sbin $PATH
set MANPATH /Library/TeX/Distributions/.DefaultTeX/Contents/Man $MANPATH

# qt
set PATH /usr/local/opt/qt/bin $PATH
set LDFLAGS "-L/usr/local/opt/qt/lib"
set CPPFLAGS "-I/usr/local/opt/qt/include"
set PKG_CONFIG_PATH "/usr/local/opt/qt/lib/pkgconfig"

# ruby
set PATH /usr/local/opt/ruby/bin $PATH
set LDFLAGS "/usr/local/opt/ruby/lib"
set CPPFLAGS "/usr/local/opt/ruby/include"
set PKG_CONFIG_PATH "/usr/local/opt/ruby/lib/pkgconfig"
set PATH $HOME/.gem/ruby/2.7.2/bin $PATH

# Poetry
set PATH $HOME/.poetry/bin $PATH

