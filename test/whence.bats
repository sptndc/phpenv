#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${PHPENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "finds versions where present" {
  create_executable "7.0" "php"
  create_executable "7.0" "php-cgi"
  create_executable "7.2" "php"
  create_executable "7.2" "phpdbg"

  run phpenv-whence php
  assert_success
  assert_output <<OUT
7.0
7.2
OUT

  run phpenv-whence php-cgi
  assert_success "7.0"

  run phpenv-whence phpdbg
  assert_success "7.2"
}
