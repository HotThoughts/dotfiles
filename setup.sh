#######################################
# Setup MacOS environment from scrach #
#######################################


# Apple development skd
xcode-select --install
# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# CLI tools
brew install git zsh tmux svn isacikgoz/taps/tldr yank parallel httpie exa fzf git-delta

# QuickLook tools on MacOS
brew install qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize suspicious-package apparency quicklookase qlvideo

# Must-have softwares
brew intall --cask notion typora raycast iterm2 visual-studio-code zoom

# DevOps tools
brew install kubectl helm kube-ps1 kubectx stern
brew install --cask google-cloud-sdk docker

# fish & fisher
brew install fish 
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

# Fonts
brew tap homebrew/cask-fonts
brew install font-inconsolata font-fira-code font-inconsolata-g-for-powerline font-inconsolata-lgc-nerd-font

# Logitech options for my mouse configuration
brew install homebrew/cask-drivers/logitech-options
