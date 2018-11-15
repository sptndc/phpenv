#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${PHPENV_ROOT}/version" ]
  run phpenv-version-origin
  assert_success "${PHPENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$PHPENV_ROOT"
  touch "${PHPENV_ROOT}/version"
  run phpenv-version-origin
  assert_success "${PHPENV_ROOT}/version"
}

@test "detects PHPENV_VERSION" {
  PHPENV_VERSION=1 run phpenv-version-origin
  assert_success "PHPENV_VERSION environment variable"
}

@test "detects local file" {
  touch .php-version
  run phpenv-version-origin
  assert_success "${PWD}/.php-version"
}

@test "detects alternate version file" {
  touch .phpenv-version
  run phpenv-version-origin
  assert_success "${PWD}/.phpenv-version"
}

@test "reports from hook" {
  mkdir -p "${PHPENV_ROOT}/phpenv.d/version-origin"
  cat > "${PHPENV_ROOT}/phpenv.d/version-origin/test.bash" <<HOOK
PHPENV_VERSION_ORIGIN=plugin
HOOK

  PHPENV_VERSION=1 PHPENV_HOOK_PATH="${PHPENV_ROOT}/phpenv.d" run phpenv-version-origin
  assert_success "plugin"
}

@test "doesn't inherit PHPENV_VERSION_ORIGIN from environment" {
  PHPENV_VERSION_ORIGIN=ignored run phpenv-version-origin
  assert_success "${PHPENV_ROOT}/version"
}
