# Shared BATS helpers for blobs tests.
#
# Strategy: shadow `mc` on $PATH with a mock that logs invocations to a file.
# Each test can inspect the log to verify expected arg shapes.
#
# Required env going into tests (setup_blobs_env sets these):
#   B2_ALIAS=test
#   B2_BUCKET=test-bucket
#   PATH="$BATS_TEST_TMPDIR/bin:$PATH"   (for mc mock)

if [ -z "${MISE_CONFIG_ROOT:-}" ]; then
  echo "MISE_CONFIG_ROOT not set — run tests via: mise run test" >&2
  exit 1
fi

# Call blobs tasks through mise.
blobs() {
  (cd "$MISE_CONFIG_ROOT" && mise run -q "$@")
}
export -f blobs

# Set up an isolated test environment:
#   - BATS_TEST_TMPDIR/bin/mc      mock mc recording invocations
#   - BATS_TEST_TMPDIR/mc.log      log of `mc` calls (one line per call)
#   - BATS_TEST_TMPDIR/mc.alias    fake alias-list content (populated by default)
#   - env: B2_ALIAS, B2_BUCKET, PATH
setup_blobs_env() {
  export B2_ALIAS="test"
  export B2_BUCKET="test-bucket"

  mkdir -p "$BATS_TEST_TMPDIR/bin"
  MC_LOG="$BATS_TEST_TMPDIR/mc.log"
  MC_ALIAS_LIST="$BATS_TEST_TMPDIR/mc.alias"
  export MC_LOG MC_ALIAS_LIST

  # By default, the alias exists (so _env passes verification).
  echo "test" > "$MC_ALIAS_LIST"

  cat > "$BATS_TEST_TMPDIR/bin/mc" <<'MCEOF'
#!/usr/bin/env bash
# Mock mc — logs args, emits canned output for alias list.
printf '%s\n' "$*" >> "$MC_LOG"
case "$1 $2" in
  "alias list") cat "$MC_ALIAS_LIST" 2>/dev/null || true ;;
  *) : ;;
esac
exit 0
MCEOF
  chmod +x "$BATS_TEST_TMPDIR/bin/mc"

  PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  export PATH
}

# Make the alias appear not-configured (for tests that assert the guard fires).
clear_mc_alias() { : > "$MC_ALIAS_LIST"; }

# Read the last mc invocation from the log.
last_mc_call() { tail -n 1 "$MC_LOG" 2>/dev/null; }

# Read all mc invocations.
all_mc_calls() { cat "$MC_LOG" 2>/dev/null; }
