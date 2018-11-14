_phpenv_commands() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $( compgen -W "$(phpenv commands)" -- $cur ) )
}

_phpenv_versions() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local versions="$(echo system; phpenv versions --bare)"
  COMPREPLY=( $( compgen -W "$versions" -- $cur ) )
}

_phpenv() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "$prev" in
  set-* | prefix )
    _phpenv_versions
    ;;
  * )
    _phpenv_commands
    ;;
  esac
}

complete -F _phpenv phpenv
