# Path to your oh-my-zsh installation.
export ZSH=/Users/sam/.oh-my-zsh
source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh

# Oh My Zsh Config
ZSH_THEME="agnoster"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
plugins=(brew bundler chruby docker gem git node npm osx rails rake ruby tmux tmuxinator vi-mode web-search xcode)

export PATH="/Users/sam/.bin:/Users/sam/Library/Android/sdk/platform-tools:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.bin/terraform"

source $ZSH/oh-my-zsh.sh
RPROMPT="%{%f%b%k%}$(build_right_prompt)"
setopt promptsubst

# Set default ruby version
chruby ruby-2.4
export EDITOR='vim'
export TERM='xterm-256color'

# My Aliases
# System
alias ll='ls -aFlh'
alias reload='source ~/.zshrc'
alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
alias setjdk18='export JAVA_HOME=$(/usr/libexec/java_hhome -v 1.8)'
alias reset_chruby='source /usr/local/opt/chruby/share/chruby/chruby.sh'
alias muxs='tmuxinator start'
alias muxn='tmuxinator new'
alias muxc='tmuxinator copy'

# Ruby
alias bi='bundle install'
alias be='bundle exec'
alias bu='bundle update'

# Elixir
alias hexu='mix local.hex'
alias iexc='iex -S mix'
alias phoenixu='mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez'
alias server='mix phoenix.server'

# Python
alias cleanpyc="find . -name '*.pyc' | xargs rm"

# JavaScript
alias chode='node'
alias cpm='npm'
alias fix_chode'npm prune ; npm cache clear ; npm install'

# Git
alias push='git push --tags origin'
alias gs='git status'
alias gc='git commit -v'
alias co='git checkout'
alias gr='git rebase'
alias pull='git pull origin'
alias glog="git log --graph --pretty=format':%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset'"

eval "$(direnv hook zsh)"
