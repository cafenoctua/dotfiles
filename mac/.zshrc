# Set shell env
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"

# Set commands alias
alias tf='terraform'
alias ll='ls -la'
alias lt='ls -lt'
alias cl='clear'
alias py='python3'
fpath+=${ZDOTDIR:-~}/.zsh_functions

# Add Docker Desktop for Mac (docker)
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"
