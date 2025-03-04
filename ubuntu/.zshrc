source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

autoload -Uz compinit
compinit

eval "$(starship init zsh)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# tfenv setup
export PATH=$HOME/.tfenv/bin:$PATH

# Set commands alias
alias tf='terraform'
alias ll='ls -la'
alias lt='ls -lt'
alias cl='clear'
alias py='python3'

# login gcloud
function glogin(){
  gcloud auth login
  gcloud auth application-default login
}

# change gcloud config
function chgc(){
  config=$1
  gcloud config configurations activate $config \
  && gcloud auth login \
  && gcloud auth application-default login
}

# list gcloud config
function lgc(){
  gcloud config configurations list
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/cafenoctia/google-cloud-sdk/path.zsh.inc' ]; then . '/home/cafenoctia/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/cafenoctia/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/cafenoctia/google-cloud-sdk/completion.zsh.inc'; fi

# Set pipx
export PIPX_DEFAULT_PYTHON=python3.12
