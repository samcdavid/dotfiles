function _current_elixir() {
  local _elixir
  _elixir="$(asdf current elixir | grep -o '[0-9]*\.[0-9]*\.[0-9]*')"
  echo -n elixir-v${_elixir}
}

function _current_node() {
  local _node
  _node="$(asdf current nodejs | grep -o '[0-9]*\.[0-9]*\.[0-9]*')"
  echo -n node-v${_node}
}

function _current_ruby() {
  local _ruby
  _ruby="$(asdf current ruby | grep -o '[0-9]*\.[0-9]*\.[0-9]*')"
  echo -n ruby-v${_ruby}
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

function dclean() {
  docker rm -v $(docker ps -a -q -f status=exited) 2> /dev/null
  docker rmi $(docker images -f "dangling=true" -q) 2> /dev/null
}

_tmuxinator() {
  local commands projects
  commands=(${(f)"$(tmuxinator commands zsh)"})
  projects=(${(f)"$(tmuxinator completions start)"})

  if (( CURRENT == 2 )); then
    _describe -t commands "tmuxinator subcommands" commands
    _describe -t projects "tmuxinator projects" projects
  elif (( CURRENT == 3)); then
    case $words[2] in
      copy|debug|delete|open|start)
        _arguments '*:projects:($projects)'
      ;;
    esac
  fi

  return
}

function end_feature() {
  git checkout master ; git pull origin master ; git branch -d $1 ; git remote prune origin
}

function super_commit() {
  git add . ; git commit -S -v ; git push origin $1
}
