#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${PHPENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${PHPENV_ROOT}/shims" ]
  run phpenv-rehash
  assert_success ""
  assert [ -d "${PHPENV_ROOT}/shims" ]
  rmdir "${PHPENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${PHPENV_ROOT}/shims"
  chmod -w "${PHPENV_ROOT}/shims"
  run phpenv-rehash
  assert_failure "phpenv: cannot rehash: ${PHPENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${PHPENV_ROOT}/shims"
  touch "${PHPENV_ROOT}/shims/.phpenv-shim"
  run phpenv-rehash
  assert_failure "phpenv: cannot rehash: ${PHPENV_ROOT}/shims/.phpenv-shim exists"
}

@test "creates shims" {
  create_executable "7.0" "php"
  create_executable "7.0" "php-cgi"
  create_executable "7.2" "php"
  create_executable "7.2" "phpdbg"

  assert [ ! -e "${PHPENV_ROOT}/shims/php" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/php-cgi" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/phpdbg" ]

  run phpenv-rehash
  assert_success ""

  run ls "${PHPENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
php
php-cgi
phpdbg
OUT
}

@test "removes outdated shims" {
  mkdir -p "${PHPENV_ROOT}/shims"
  touch "${PHPENV_ROOT}/shims/oldshim1"
  chmod +x "${PHPENV_ROOT}/shims/oldshim1"

  create_executable "7.2" "php"
  create_executable "7.2" "php-cgi"

  run phpenv-rehash
  assert_success ""

  assert [ ! -e "${PHPENV_ROOT}/shims/oldshim1" ]
}

@test "do exact matches when removing stale shims" {
  create_executable "7.2" "phpdbg"
  create_executable "7.2" "phar"

  phpenv-rehash

  cp "$PHPENV_ROOT"/shims/{phar,phpcbf}
  cp "$PHPENV_ROOT"/shims/{phar,phpcs}
  cp "$PHPENV_ROOT"/shims/{phar,phpunit}
  chmod +x "$PHPENV_ROOT"/shims/{phpcbf,phpcs,phpunit}

  run phpenv-rehash
  assert_success ""

  assert [ ! -e "${PHPENV_ROOT}/shims/phpcbf" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/phpcs" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/phpunit" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 RC1" "php"
  create_executable "dirname2 beta1" "phpize"

  assert [ ! -e "${PHPENV_ROOT}/shims/php" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/phpize" ]

  run phpenv-rehash
  assert_success ""

  run ls "${PHPENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
php
phpize
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run phpenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "7.2" "php"
  PHPENV_SHELL=bash run phpenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${PHPENV_ROOT}/shims/php" ]
}

@test "sh-rehash in fish" {
  create_executable "7.2" "php"
  PHPENV_SHELL=fish run phpenv-sh-rehash
  assert_success ""
  assert [ -x "${PHPENV_ROOT}/shims/php" ]
}
