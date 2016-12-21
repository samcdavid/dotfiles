function _current_elixir() {
  local _elixir
  _elixir="$(elixir -v | grep \Elixir)"
  echo -n ${_elixir}
}

function _current_node() {
  local _node
  _node="node-$(node -v)"
  echo -n ${_node}
}

function _current_ruby() {
  local _ruby
  _ruby="$(chruby |grep \* |tr -d '* ')"
  if [[ $(chruby |grep -c \*) -eq 1 ]]; then
    echo -n ${_ruby}
  else
    echo -n "System Ruby"
  fi
}

function my_current_elixir() {
  prompt_segment green black '$(_current_elixir)'
}

function my_current_node() {
  prompt_segment yellow black '$(_current_node)'
}

function my_current_ruby() {
  prompt_segment red black '$(_current_ruby)'
}

function build_right_prompt() {
  prompt_segment
  my_current_ruby
  my_current_node
  my_current_elixir
  prompt_end
}
eval "$(/usr/local/opt/hop/bin/hop init -)"

function dclean() {
  docker rm -v $(docker ps -a -q -f status=exited) 2> /dev/null
  docker rmi $(docker images -f "dangling=true" -q) 2> /dev/null
}
