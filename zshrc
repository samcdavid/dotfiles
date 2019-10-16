# Path to your oh-my-zsh installation.
export ZSH=/Users/sam/.oh-my-zsh

# Oh My Zsh Config
ZSH_THEME="agnoster"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
plugins=(brew bundler docker docker-compose gem git node npm osx rake ruby tmux tmuxinator vi-mode web-search xcode mix-fast)

export PATH="/Users/sam/.bin:/Users/sam/Library/Android/sdk/platform-tools:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.bin/terraform"

source $ZSH/oh-my-zsh.sh
source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash
RPROMPT="%{%f%b%k%}$(build_right_prompt)"
setopt promptsubst

# gcloud autocompletions
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'

# Set default ruby version
export EDITOR='nvim'
export TERM='xterm-256color'

# Setup Python Virtual Env BS
export PYTHON_VERSION="$(python -V | grep -o '[0-9]*\.[0-9]*\.[0-9]*')"
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Developer
source ~/.asdf/installs/python/$PYTHON_VERSION/bin/virtualenvwrapper.sh
export PATH="~/.asdf/installs/python/$PYTHON_VERSION/bin:$PATH"

# Personal Environment Variables
export ERL_AFLAGS="-kernel shell_history enabled"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""'

# My Aliases
# System
alias ll='ls -aFlh'
alias muxc='tmuxinator copy'
alias muxn='tmuxinator new'
alias muxs='tmuxinator start'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias reload='source ~/.zshrc'
alias setjdk18='export JAVA_HOME=$(/usr/libexec/java_hhome -v 1.8)'
alias vim='nvim'

# Ruby
alias be='bundle exec'
alias bi='bundle install'
alias bu='bundle update'

# Elixir
alias hexu='mix local.hex'
alias rebaru='mix local.rebar --force'
alias iexc='iex -S mix'
alias phoenixu='mix archive.install hex phx_new'
alias server='mix phx.server'

# Postgres (ASDF)
alias pg_init="createuser -s postgres"
alias pg_start="pg_ctl -l /dev/null start"
alias pg_stop="pg_ctl stop"
alias pg_user="createuser -s postgres"

# Python
alias cleanpyc="find . -name '*.pyc' | xargs rm"

# JavaScript
alias chode='node'
alias cpm='npm'
alias fix_chode'npm prune ; npm cache clear ; npm install'

# Git
alias push='git push --tags origin'
alias gs='git status'
alias gc='git commit -S -v'
alias co='git checkout'
alias gr='git rebase'
alias pull='git pull origin'
alias glog="git log --graph --pretty=format':%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset'"
alias shove='git push -f --tags origin'

# Docker
alias stop_docker='docker stop $(docker ps -aq)'
alias rm_docker='docker rm $(docker ps -aq)'

eval "$(direnv hook zsh)"

compdef _tmuxinator tmuxinator mux
alias mux="tmuxinator"
