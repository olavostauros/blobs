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

# ─── Google Drive (rclone) helpers ───────────────────────────────────────────
#
# Set up an isolated test environment for drive tasks:
#   - BATS_TEST_TMPDIR/bin/rclone      mock rclone recording invocations
#   - BATS_TEST_TMPDIR/rclone.log      log of `rclone` calls (one line per call)
#   - BATS_TEST_TMPDIR/rclone.remotes  fake listremotes output (populated by default)
#   - BATS_TEST_TMPDIR/sa-key.json     fake service account key file (0600)
#   - env: GDRIVE_REMOTE, GDRIVE_SA_KEY_FILE, GDRIVE_FOLDER_ID, PATH
setup_drive_env() {
  export GDRIVE_REMOTE="test-drive"
  export GDRIVE_FOLDER_ID="test-folder-id"

  mkdir -p "$BATS_TEST_TMPDIR/bin"
  RCLONE_LOG="$BATS_TEST_TMPDIR/rclone.log"
  RCLONE_REMOTES="$BATS_TEST_TMPDIR/rclone.remotes"
  export RCLONE_LOG RCLONE_REMOTES

  # Fake SA key file outside MISE_CONFIG_ROOT with correct permissions.
  GDRIVE_SA_KEY_FILE="$BATS_TEST_TMPDIR/sa-key.json"
  export GDRIVE_SA_KEY_FILE
  echo '{"type":"service_account"}' > "$GDRIVE_SA_KEY_FILE"
  chmod 600 "$GDRIVE_SA_KEY_FILE"

  # By default, the remote exists (so drive:_env passes verification).
  echo "test-drive:" > "$RCLONE_REMOTES"

  cat > "$BATS_TEST_TMPDIR/bin/rclone" <<'RCLONEEOF'
#!/usr/bin/env bash
# Mock rclone — logs args, emits canned output for listremotes.
printf '%s\n' "$*" >> "$RCLONE_LOG"
case "$1" in
  listremotes) cat "$RCLONE_REMOTES" 2>/dev/null || true ;;
  *) : ;;
esac
exit 0
RCLONEEOF
  chmod +x "$BATS_TEST_TMPDIR/bin/rclone"

  PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  export PATH
}

# Make the remote appear not-configured (for tests that assert the guard fires).
clear_drive_remote() { : > "$RCLONE_REMOTES"; }

# Read the last rclone invocation from the log.
last_rclone_call() { tail -n 1 "$RCLONE_LOG" 2>/dev/null; }

# Read all rclone invocations.
all_rclone_calls() { cat "$RCLONE_LOG" 2>/dev/null; }
