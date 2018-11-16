#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${PHPENV_TEST_DIR}/myproject"
  cd "${PHPENV_TEST_DIR}/myproject"
}

@test "fails without arguments" {
  run phpenv-version-file-read
  assert_failure ""
}

@test "fails for invalid file" {
  run phpenv-version-file-read "non-existent"
  assert_failure ""
}

@test "fails for blank file" {
  echo > my-version
  run phpenv-version-file-read my-version
  assert_failure ""
}

@test "reads simple version file" {
  cat > my-version <<<"7.1.23"
  run phpenv-version-file-read my-version
  assert_success "7.1.23"
}

@test "ignores leading spaces" {
  cat > my-version <<<"  7.1.23"
  run phpenv-version-file-read my-version
  assert_success "7.1.23"
}

@test "reads only the first word from file" {
  cat > my-version <<<"7.1.23@tag 7.0.32 hi"
  run phpenv-version-file-read my-version
  assert_success "7.1.23@tag"
}

@test "loads only the first line in file" {
  cat > my-version <<IN
7.0.32 one
7.1.23 two
IN
  run phpenv-version-file-read my-version
  assert_success "7.0.32"
}

@test "ignores leading blank lines" {
  cat > my-version <<IN

7.1.23
IN
  run phpenv-version-file-read my-version
  assert_success "7.1.23"
}

@test "handles the file with no trailing newline" {
  echo -n "7.0.32" > my-version
  run phpenv-version-file-read my-version
  assert_success "7.0.32"
}

@test "ignores carriage returns" {
  cat > my-version <<< $'7.1.23\r'
  run phpenv-version-file-read my-version
  assert_success "7.1.23"
}
