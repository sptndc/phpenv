#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${PHPENV_TEST_DIR}/myproject"
  cd "${PHPENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.php-version" ]
  run phpenv-local
  assert_failure "phpenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .php-version
  run phpenv-local
  assert_success "1.2.3"
}

@test "supports legacy .phpenv-version file" {
  echo "1.2.3" > .phpenv-version
  run phpenv-local
  assert_success "1.2.3"
}

@test "local .php-version has precedence over .phpenv-version" {
  echo "7.0" > .phpenv-version
  echo "7.2" > .php-version
  run phpenv-local
  assert_success "7.2"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .php-version
  mkdir -p "subdir" && cd "subdir"
  run phpenv-local
  assert_success "1.2.3"
}

@test "ignores PHPENV_DIR" {
  echo "1.2.3" > .php-version
  mkdir -p "$HOME"
  echo "7.2-home" > "${HOME}/.php-version"
  PHPENV_DIR="$HOME" run phpenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${PHPENV_ROOT}/versions/1.2.3"
  run phpenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .php-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "5.6-pre" > .php-version
  mkdir -p "${PHPENV_ROOT}/versions/1.2.3"
  run phpenv-local
  assert_success "5.6-pre"
  run phpenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .php-version)" = "1.2.3" ]
}

@test "renames .phpenv-version to .php-version" {
  echo "7.0.32" > .phpenv-version
  mkdir -p "${PHPENV_ROOT}/versions/7.1.23"
  run phpenv-local
  assert_success "7.0.32"
  run phpenv-local "7.1.23"
  assert_success
  assert_output <<OUT
phpenv: removed existing \`.phpenv-version' file and migrated
        local version specification to \`.php-version' file
OUT
  assert [ ! -e .phpenv-version ]
  assert [ "$(cat .php-version)" = "7.1.23" ]
}

@test "doesn't rename .phpenv-version if changing the version failed" {
  echo "7.0.32" > .phpenv-version
  assert [ ! -e "${PHPENV_ROOT}/versions/7.1.23" ]
  run phpenv-local "7.1.23"
  assert_failure "phpenv: version \`7.1.23' not installed"
  assert [ ! -e .php-version ]
  assert [ "$(cat .phpenv-version)" = "7.0.32" ]
}

@test "unsets local version" {
  touch .php-version
  run phpenv-local --unset
  assert_success ""
  assert [ ! -e .phpenv-version ]
}

@test "unsets alternate version file" {
  touch .phpenv-version
  run phpenv-local --unset
  assert_success ""
  assert [ ! -e .phpenv-version ]
}
