# Path to your oh-my-zsh installation.
export ZSH=/Users/sam/.oh-my-zsh

# Oh My Zsh Config
ZSH_THEME="agnoster"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
plugins=(brew bundler docker gem git node npm osx rails rake ruby tmux tmuxinator vi-mode web-search xcode mix-fast)

export PATH="/Users/sam/.bin:/Users/sam/Library/Android/sdk/platform-tools:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.bin/terraform"

eval "$(/usr/local/opt/hop/bin/hop init -)"
source $ZSH/oh-my-zsh.sh
source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash
RPROMPT="%{%f%b%k%}$(build_right_prompt)"
setopt promptsubst

# Set default ruby version
export EDITOR='mvim -v'
export TERM='xterm-256color'

# Personal Environment Variables
export ERL_AFLAGS="-kernel shell_history enabled"

# My Aliases
# System
alias ll='ls -aFlh'
alias reload='source ~/.zshrc'
alias setjdk18='export JAVA_HOME=$(/usr/libexec/java_hhome -v 1.8)'
alias muxs='tmuxinator start'
alias muxn='tmuxinator new'
alias muxc='tmuxinator copy'
alias vim='mvim -v'

# Ruby
alias bi='bundle install'
alias be='bundle exec'
alias bu='bundle update'

# Elixir
alias hexu='mix local.hex'
alias iexc='iex -S mix'
alias phoenixu='mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez'
alias server='mix phx.server'

# Postgres (ASDF)
alias pg_init="createuser -s postgres"
alias pg_start="pg_ctl -l /dev/null start"
alias pg_stop="pg_ctl stop"

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

eval "$(direnv hook zsh)"
