#compdef _phpenv phpenv

function _phpenv_commands() {
  cmds_str="$(phpenv commands)"
  cmds=("${(ps:\n:)cmds_str}")
  _describe '_phpenv_commands' cmds
}

_phpenv_versions() {
  versions_str="$(phpenv versions --bare)"
  versions=(system "${(ps:\n:)versions_str}")
  _describe '_phpenv_versions' versions
}

_phpenv() {
  case "$words[2]" in
    set-local | set-default | prefix ) _phpenv_versions ;;
    * ) _phpenv_commands ;;
  esac
}
