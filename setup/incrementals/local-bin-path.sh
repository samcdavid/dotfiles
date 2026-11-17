#!/bin/bash

# Puts ~/.local/bin at the front of PATH for fish, bash, and zsh, so wrappers
# installed there (e.g. git) shadow the system binaries. Safe to re-run, and
# works unmodified on mac and Ubuntu. Standalone: it needs nothing else from
# this repo, so it can be handed to someone else as-is.
#
#   local-bin-path.sh              # every installed shell
#   local-bin-path.sh zsh fish     # only the shells named
#
# bash and zsh get a marked block appended to each startup file the shell may
# read, because later lines in those files (brew shellenv, version managers)
# prepend to PATH and would otherwise push ~/.local/bin back down. fish gets
# its universal fish_user_paths set instead of a file edit: it persists, it
# applies to non-interactive fish too, and it leaves a config.fish that is
# symlinked into a dotfiles repo untouched.

set -e

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

BLOCK_BEGIN='# >>> local-bin-path >>>'

# The block is sourced by dash on Ubuntu (a login ~/.profile) as well as by
# bash and zsh, so it sticks to POSIX: no ${var//x/y}, no arrays, no
# word-splitting on an unquoted $PATH (zsh doesn't split). It walks PATH with
# parameter expansion instead of forking tr/grep, since it runs at every shell
# start.
print_block() {
  cat <<'EOF'
# >>> local-bin-path >>>
# Keeps ~/.local/bin ahead of system directories so wrappers installed there
# (e.g. git) win. Managed by local-bin-path.sh; delete the block to undo.
case $PATH in
  "$HOME/.local/bin":*) ;;
  *)
    __lb_rest=$PATH
    __lb_new=$HOME/.local/bin
    while [ -n "$__lb_rest" ]; do
      case $__lb_rest in
        *:*) __lb_dir=${__lb_rest%%:*}; __lb_rest=${__lb_rest#*:} ;;
        *)   __lb_dir=$__lb_rest; __lb_rest= ;;
      esac
      [ "$__lb_dir" = "$HOME/.local/bin" ] || __lb_new=$__lb_new:$__lb_dir
    done
    PATH=$__lb_new
    export PATH
    unset __lb_rest __lb_new __lb_dir
    ;;
esac
# <<< local-bin-path <<<
EOF
}

# Append-only on purpose: `>>` writes through a symlinked startup file instead
# of replacing the link, and an existing block is never rewritten.
add_block() {
  local file="$1"
  if [ -f "$file" ] && grep -qF "$BLOCK_BEGIN" "$file"; then
    echo "  already set: $file"
    return
  fi
  if [ -s "$file" ]; then
    # Without this the block glues onto an unterminated last line.
    [ -z "$(tail -c1 "$file")" ] || printf '\n' >> "$file"
    printf '\n' >> "$file"
  fi
  print_block >> "$file"
  echo "  updated: $file"
}

configure_bash() {
  # Bash reads only the first of these at login, so adding .bash_profile when
  # only .profile exists would stop bash from reading .profile at all.
  local login=.bash_profile f
  for f in .bash_profile .bash_login .profile; do
    if [ -f "$HOME/$f" ]; then
      login=$f
      break
    fi
  done
  add_block "$HOME/$login"
  add_block "$HOME/.bashrc"
}

configure_zsh() {
  local dir="${ZDOTDIR:-$HOME}"
  # .zprofile, not just .zshenv: on macOS /etc/zprofile runs path_helper,
  # which moves system directories back in front of whatever .zshenv set.
  add_block "$dir/.zshenv"
  add_block "$dir/.zprofile"
  add_block "$dir/.zshrc"
}

configure_fish() {
  # Single-quoted on purpose: this is fish code, and fish must expand $HOME.
  # shellcheck disable=SC2016
  fish -c '
    set -l dir $HOME/.local/bin
    if test "$fish_user_paths[1]" = "$dir"
      echo "  already set: fish_user_paths"
    else
      set -l rest
      for p in $fish_user_paths
        test "$p" = "$dir"; or set rest $rest $p
      end
      set -U fish_user_paths $dir $rest
      echo "  updated: fish_user_paths (universal variable)"
    end
  '
}

shells=("$@")
[ ${#shells[@]} -gt 0 ] || shells=(bash zsh fish)

for shell in "${shells[@]}"; do
  case "$shell" in
    bash|zsh|fish) ;;
    *)
      fancy_echo "Error: unknown shell '%s' (expected bash, zsh, or fish)." "$shell"
      exit 1
      ;;
  esac
  if ! command -v "$shell" >/dev/null 2>&1; then
    fancy_echo "Skipping %s: not installed." "$shell"
    continue
  fi
  fancy_echo "Configuring %s..." "$shell"
  "configure_$shell"
done

fancy_echo "Done. Open a new terminal (or run: exec \$SHELL -l), then check that this prints %s:
  echo \"\$PATH\" | tr ':' '\\\\n' | head -1
Apps launched from the Dock or Finder don't read shell startup files and keep launchd's PATH." "$HOME/.local/bin"
