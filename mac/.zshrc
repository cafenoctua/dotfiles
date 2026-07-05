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

# ASFD
PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

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

export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
eval "$(mise activate zsh)"

# Added by dbt installer
export PATH="$PATH:$HOME/.local/bin"

# dbt aliases
alias dbtf=$HOME/.local/bin/dbt

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Ghostty + Zellij: Ghostty 起動時に自動で Zellij セッションを開始
if [ -n "$GHOSTTY_RESOURCES_DIR" ] && [ -z "$ZELLIJ" ]; then
  zellij
fi

# direnv hook (per-directory env, e.g. dbt-core の dbt shim)
eval "$(direnv hook zsh)"
