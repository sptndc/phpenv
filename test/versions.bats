#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PHPENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
}

stub_system_php() {
  local stub="${PHPENV_TEST_DIR}/bin/php"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_php
  assert [ ! -d "${PHPENV_ROOT}/versions" ]
  run phpenv-versions
  assert_success "* system (set by ${PHPENV_ROOT}/version)"
}

@test "not even system php available" {
  PATH="$(path_without php)" run phpenv-versions
  assert_failure
  assert_output "Warning: no PHP detected on the system"
}

@test "bare output no versions installed" {
  assert [ ! -d "${PHPENV_ROOT}/versions" ]
  run phpenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_php
  create_version "7.1"
  run phpenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${PHPENV_ROOT}/version)
  7.1
OUT
}

@test "single version bare" {
  create_version "7.1"
  run phpenv-versions --bare
  assert_success "7.1"
}

@test "multiple versions" {
  stub_system_php
  create_version "7.0.32"
  create_version "7.1.23"
  create_version "7.2.0"
  run phpenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${PHPENV_ROOT}/version)
  7.0.32
  7.1.23
  7.2.0
OUT
}

@test "indicates current version" {
  stub_system_php
  create_version "7.1.23"
  create_version "7.2.0"
  PHPENV_VERSION=7.1.23 run phpenv-versions
  assert_success
  assert_output <<OUT
  system
* 7.1.23 (set by PHPENV_VERSION environment variable)
  7.2.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "7.1.23"
  create_version "7.2.0"
  PHPENV_VERSION=7.1.23 run phpenv-versions --bare
  assert_success
  assert_output <<OUT
7.1.23
7.2.0
OUT
}

@test "globally selected version" {
  stub_system_php
  create_version "7.1.23"
  create_version "7.2.0"
  cat > "${PHPENV_ROOT}/version" <<<"7.1.23"
  run phpenv-versions
  assert_success
  assert_output <<OUT
  system
* 7.1.23 (set by ${PHPENV_ROOT}/version)
  7.2.0
OUT
}

@test "per-project version" {
  stub_system_php
  create_version "7.1.23"
  create_version "7.2.0"
  cat > ".php-version" <<<"7.1.23"
  run phpenv-versions
  assert_success
  assert_output <<OUT
  system
* 7.1.23 (set by ${PHPENV_TEST_DIR}/.php-version)
  7.2.0
OUT
}

@test "ignores non-directories under versions" {
  create_version "7.1"
  touch "${PHPENV_ROOT}/versions/hello"

  run phpenv-versions --bare
  assert_success "7.1"
}

@test "lists symlinks under versions" {
  create_version "7.0.32"
  ln -s "7.0.32" "${PHPENV_ROOT}/versions/7.0"

  run phpenv-versions --bare
  assert_success
  assert_output <<OUT
7.0
7.0.32
OUT
}

@test "doesn't list symlink aliases when --skip-aliases" {
  create_version "7.0.32"
  ln -s "7.0.32" "${PHPENV_ROOT}/versions/7.0"
  mkdir moo
  ln -s "${PWD}/moo" "${PHPENV_ROOT}/versions/7.1"

  run phpenv-versions --bare --skip-aliases
  assert_success

  assert_output <<OUT
7.0.32
7.1
OUT
}
