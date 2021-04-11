#######################################
# Setup MacOS environment from scrach #
#######################################


# Apple development skd
xcode-select --install
# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# CLI tools
brew install git zsh tmux svn tldr yank parallel

# Must-have softwares
brew intall --cask notion typora raycast iterm2 visual-studio-code zoom

# DevOps tools
brew install kubectl helm kube-ps1 kubectx stern
brew install --cask google-cloud-sdk docker

# oh-my-zsh & plugins
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Fonts
brew tap homebrew/cask-fonts
brew install font-inconsolata font-fira-code font-inconsolata-g-for-powerline

# Logitech options for my mouse configuration
brew install homebrew/cask-drivers/logitech-options
