# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Plugins to load
plugins=(
    git
    docker
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='code'

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias gs='git status'
alias gp='git pull'
alias gpush='git push'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias dc='docker-compose'
alias d='docker'
alias k='kubectl'
alias python='python3'
alias pip='pip3'

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Load Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Load custom scripts
if [ -d "$HOME/.scripts" ]; then
    export PATH="$HOME/.scripts:$PATH"
fi

# Enable color support
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
