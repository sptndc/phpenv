#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${PHPENV_ROOT}/versions/${PHPENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export PHPENV_VERSION="2.0"
  run phpenv-exec php -v
  assert_failure "phpenv: version \`2.0' is not installed (set by PHPENV_VERSION environment variable)"
}

@test "fails with invalid version set from file" {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
  echo 7.1 > .php-version
  run phpenv-exec phpize
  assert_failure "phpenv: version \`7.1' is not installed (set by $PWD/.php-version)"
}

@test "completes with names of executables" {
  export PHPENV_VERSION="7.2"
  create_executable "php" "#!/bin/sh"
  create_executable "php-cgi" "#!/bin/sh"

  phpenv-rehash
  run phpenv-completions exec
  assert_success
  assert_output <<OUT
--help
php
php-cgi
OUT
}

@test "supports hook path with spaces" {
  hook_path="${PHPENV_TEST_DIR}/custom stuff/phpenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export PHPENV_VERSION=system
  PHPENV_HOOK_PATH="$hook_path" run phpenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${PHPENV_TEST_DIR}/phpenv.d"
  mkdir -p "${hook_path}/exec"
  cat > "${hook_path}/exec/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PHPENV_VERSION=system
  PHPENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run phpenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export PHPENV_VERSION="7.2"
  create_executable "php" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run phpenv-exec php -w "/path to/php script.php" -- extra args
  assert_success
  assert_output <<OUT
${PHPENV_ROOT}/versions/7.2/bin/php
  -w
  /path to/php script.php
  --
  extra
  args
OUT
}
