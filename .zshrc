# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
# ZSH_THEME=$THEME
THEME="shades-of-purple"

if [[ -n $SSH_CONNECTION ]]; then
  #ZSH_THEME="robbyrussell"
  ZSH_THEME=$THEME
else
  ZSH_THEME=$THEME
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" "avit" )

# Shell Integration with tmux 
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git
	 tmux
	 brew
	 python
	 ssh-agent
	 zsh-navigation-tools
	 z
	 zsh-completions
	 zsh-autosuggestions
	 zsh-syntax-highlighting
	 ruby
	 poetry
	 docker-compose
	 vi-mode
	 )
# zsh-completions
autoload -U compinit && compinit

# ssh-agent config
zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities id_rsa id_synergeticon id_unihamburg 
zstyle :omz:plugins:ssh-agent lifetime 4h

# enable vi mode
bindkey -v

########################
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"


# Install ARM compatible software 
# if [ -d "/opt/homebrew/bin" ]; then
#     export PATH="/opt/homebrew/bin:$PATH"
# fi
# If you really want to install Intel software, use ibrew
# function ibrew() {
#    arch --x86_64 /usr/local/bin/brew $@
# }


# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Aliases
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias zshrc="vim ~/.zshrc"
alias vimrc="vim ~/.vimrc"
alias tmux.conf="vim ~/.tmux.conf"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias sshconfig="vim ~/.ssh/config"
alias pip="pip3"
alias python="python3"
alias update_comet_ml="pip3 install comet_ml --upgrade --upgrade-strategy eager"

# BasicTeX
alias texupdate="sudo tlmgr update --self && sudo tlmgr update --all"
alias texinstall="sudo tlmgr install"
export PATH="/usr/local/sbin:$PATH"
export MANPATH="/Library/TeX/Distributions/.DefaultTeX/Contents/Man:$MANPATH"

# qt
export PATH="/usr/local/opt/qt/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/qt/lib"
export CPPFLAGS="-I/usr/local/opt/qt/include"
export PKG_CONFIG_PATH="/usr/local/opt/qt/lib/pkgconfig"

# ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"
export LDFLAGS="/usr/local/opt/ruby/lib"
export CPPFLAGS="/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"
export PATH="$HOME/.gem/ruby/2.7.2/bin:$PATH"

# Poetry
export PATH="$HOME/.poetry/bin:$PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform
