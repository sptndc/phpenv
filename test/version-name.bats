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
  run phpenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  PHPENV_VERSION=system run phpenv-version-name
  assert_success "system"
}

@test "PHPENV_VERSION can be overridden by hook" {
  create_version "7.0.32"
  create_version "7.1.23"
  create_hook version-name test.bash <<<"PHPENV_VERSION=7.1.23"

  PHPENV_VERSION=7.0.32 run phpenv-version-name
  assert_success "7.1.23"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PHPENV_VERSION=system
  IFS=$' \t\n' run phpenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "PHPENV_VERSION has precedence over local" {
  create_version "7.0.32"
  create_version "7.1.23"

  cat > ".php-version" <<<"7.0.32"
  run phpenv-version-name
  assert_success "7.0.32"

  PHPENV_VERSION=7.1.23 run phpenv-version-name
  assert_success "7.1.23"
}

@test "local file has precedence over global" {
  create_version "7.0.32"
  create_version "7.1.23"

  cat > "${PHPENV_ROOT}/version" <<<"7.0.32"
  run phpenv-version-name
  assert_success "7.0.32"

  cat > ".php-version" <<<"7.1.23"
  run phpenv-version-name
  assert_success "7.1.23"
}

@test "missing version" {
  PHPENV_VERSION=1.2 run phpenv-version-name
  assert_failure "phpenv: version \`1.2' is not installed (set by PHPENV_VERSION environment variable)"
}

@test "version with prefix in name" {
  create_version "7.0.32"
  cat > ".php-version" <<<"php-7.0.32"
  run phpenv-version-name
  assert_success
  assert_output "7.0.32"
}
