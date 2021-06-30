# Path to your oh-my-zsh installation.
export ZSH=/Users/sam/.oh-my-zsh

# Oh My Zsh Config
ZSH_THEME="agnoster"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
ZSH_DISABLE_COMPFIX=true
plugins=(brew bundler docker docker-compose gem git node npm osx poetry rake ruby tmux tmuxinator vi-mode web-search xcode mix-fast)

export PATH="/Users/sam/.bin:/Users/sam/Library/Android/sdk/platform-tools:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.bin/terraform:$HOME/.poetry/bin"
fpath+=~/.zfunc

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
export PROJECT_HOME=$HOME/Developer
export PATH="~/.asdf/installs/python/$PYTHON_VERSION/bin:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"

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
alias setjdk18='export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)'
alias vim='nvim'
alias tf='terraform'

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

# Java
export JAVA_HOME=/Users/sam/.asdf/installs/java/oracle-8.141

# Git
alias push='git push --tags origin'
alias gs='git status'
alias gc='git commit -S -v'
alias co='git checkout'
alias gr='git rebase'
alias pull='git pull origin'
alias pap='pull && git fetch && git remote prune origin'
alias glog="git log --graph --pretty=format':%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset'"
alias shove='git push -f --tags origin'

# Docker
alias stop_docker='docker stop $(docker ps -aq)'
alias rm_docker='docker rm $(docker ps -aq)'
alias rmi_docker='docker rmi $(docker images -aq)'

eval "$(direnv hook zsh)"

compdef _tmuxinator tmuxinator mux
alias mux="tmuxinator"

## >>> conda initialize >>>
## !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$('/Users/sam/.asdf/installs/python/anaconda3-2020.11/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    eval "$__conda_setup"
#else
#    if [ -f "/Users/sam/.asdf/installs/python/anaconda3-2020.11/etc/profile.d/conda.sh" ]; then
#        . "/Users/sam/.asdf/installs/python/anaconda3-2020.11/etc/profile.d/conda.sh"
#    else
#        export PATH="/Users/sam/.asdf/installs/python/anaconda3-2020.11/bin:$PATH"
#    fi
#fi
#unset __conda_setup
## <<< conda initialize <<<

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

autoload -U +X bashcompinit && bashcompinit

complete -o nospace -C /Users/sam/.asdf/installs/terraform/1.0.1/bin/terraform terraform
