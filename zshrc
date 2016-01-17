export PATH="$HOME/.bin:$PATH"

# recommended by brew doctor
export PATH="/usr/local/bin:$PATH"

source /usr/local/opt/chruby/share/chruby/chruby.sh

# source /usr/local/share/zsh/site-functions/_aws

autoload -U compinit promptinit colors select-word-style
compinit
promptinit
colors
select-word-style shell
setopt completeinword
setopt auto_cd
REPORTTIME=10
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# My Aliases
# System
alias ll='ls -aFlh'
alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
alias setjdk18='export JAVA_HOME=$(/usr/libexec/java_hhome -v 1.8)'
alias reset_chruby='source /usr/local/opt/chruby/share/chruby/chruby.sh'

# Ruby
alias bi='bundle install'
alias be='bundle exec'
alias bu='bundle update'

# Git
alias push='git push --tags origin'
alias gs='git status'
alias gc='git commit -v'
alias co='git checkout'
alias gr='git rebase -i'
alias pull='git pull origin'
alias glog="git log --graph --pretty=format':%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset'"

# Functions
function _current_ruby() {
  local _ruby
  _ruby="$(chruby |grep \* |tr -d '* ')"
  if [[ $(chruby |grep -c \*) -eq 1 ]]; then
    echo ${_ruby}
  else
    echo "SYSTEM"
  fi
}

function _current_node() {
  local _node
  _node="node-$(node -v)"
  echo ${_node}
}

function _current_elixir() {
  local _elixir
  _elixir="$(elixir -v | grep \Elixir)"
  echo ${_elixir}
}

function _git_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  echo ${ref#refs/heads/}
}

function _parse_git_dirty() {
  local STATUS=''
  local OUTPUT=''
  local FLAGS
  FLAGS=('--porcelain')
  STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  if [[ -n $STATUS ]]; then
    OUTPUT=' %F{red}\xE2\x9C\x97%f '
  elif [[ $(ll .git 2> /dev/null | grep -c \total) -eq 1 ]]; then
    OUTPUT=' %F{green}\xE2\x9C\x93%f '
  fi
  if [[ $(git diff --staged --name-status 2> /dev/null | tail -n1) != "" ]]; then
    OUTPUT=${OUTPUT}'%F{yellow}\xE2\x98\x85%f '
  fi
  echo ${OUTPUT}
}

function current_ruby() {
  echo '$(_current_ruby)'
}

function current_node() {
  echo '$(_current_node)'
}

function current_elixir() {
  echo '$(_current_elixir)'
}

function git_branch() {
  echo '$(_git_branch)'
}

function parse_git_dirty() {
  if [[ $(_parse_git_dirty) != '' ]]; then
    echo '$(_parse_git_dirty)'
  fi
}

# Prompt
PROMPT="%B%F{red}$(current_ruby)%f : %F{yellow}$(current_node)%f : %F{green}$(current_elixir)%f : %F{blue}$(git_branch)%f%b$(parse_git_dirty)> "
RPROMPT="%F{green%}%~%f"
setopt promptsubst
