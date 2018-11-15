#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PHPENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${PHPENV_ROOT}/versions" ]
  run phpenv-version
  assert_success "system (set by ${PHPENV_ROOT}/version)"
}

@test "set by PHPENV_VERSION" {
  create_version "7.1.23"
  PHPENV_VERSION=7.1.23 run phpenv-version
  assert_success "7.1.23 (set by PHPENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "7.1.23"
  cat > ".php-version" <<<"7.1.23"
  run phpenv-version
  assert_success "7.1.23 (set by ${PWD}/.php-version)"
}

@test "set by global file" {
  create_version "7.1.23"
  cat > "${PHPENV_ROOT}/version" <<<"7.1.23"
  run phpenv-version
  assert_success "7.1.23 (set by ${PHPENV_ROOT}/version)"
}
