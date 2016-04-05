
# Put homebrew items first
set PATH /usr/local/bin $PATH

# Go environment
set PATH $HOME/Projects/go/bin $PATH
set -x GOPATH $HOME/Projects/go
set -x GO15VENDOREXPERIMENT 1

# Docker environment
mkdir -p ~/Documents/Docker
set -x DOCKER_CONFIG ~/Documents/Docker
set -x MACHINE_STORAGE_PATH ~/Documents/Docker

# Conveniences
alias .. 'cd ..'
alias md 'mkdir -p'
alias cx 'chmod +x'
alias c-x 'chmod -x'
alias ll 'ls -lah'
alias tmx 'tmuxomatic ~/.dotfiles/tmux/mikattack'

