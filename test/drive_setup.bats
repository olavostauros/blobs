#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_drive_env
  clear_drive_remote  # setup task creates the remote; start from not-configured
}

# Gap 3: teardown removes any key file that the "key inside repo" test may have
# placed inside MISE_CONFIG_ROOT. Runs after every test, including on assertion
# failure, so the file never persists between runs.
teardown() {
  rm -f "$MISE_CONFIG_ROOT/sa-key.json" 2>/dev/null || true
}

@test "drive:setup: configures rclone remote when all env vars present" {
  run blobs drive:setup
  [ "$status" -eq 0 ]
  [[ "$output" == *"Drive remote configured"* ]]
  calls=$(all_rclone_calls)
  [[ "$calls" == *"config create test-drive drive"* ]]
  [[ "$calls" == *"service_account_file"* ]]
  [[ "$calls" == *"root_folder_id test-folder-id"* ]]
  [[ "$calls" == *"scope drive.readonly"* ]]
}

@test "drive:setup: fails without GDRIVE_REMOTE" {
  unset GDRIVE_REMOTE
  run blobs drive:setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"GDRIVE_REMOTE"* ]]
}

@test "drive:setup: fails without GDRIVE_SA_KEY_FILE" {
  unset GDRIVE_SA_KEY_FILE
  run blobs drive:setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"GDRIVE_SA_KEY_FILE"* ]]
}

@test "drive:setup: fails without GDRIVE_FOLDER_ID" {
  unset GDRIVE_FOLDER_ID
  run blobs drive:setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"GDRIVE_FOLDER_ID"* ]]
}

@test "drive:setup: reports multiple missing vars together" {
  unset GDRIVE_SA_KEY_FILE GDRIVE_FOLDER_ID
  run blobs drive:setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"GDRIVE_SA_KEY_FILE"* ]]
  [[ "$output" == *"GDRIVE_FOLDER_ID"* ]]
}

@test "drive:setup: fails when SA key file does not exist" {
  export GDRIVE_SA_KEY_FILE="$BATS_TEST_TMPDIR/no-such-file.json"
  run blobs drive:setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found or not readable"* ]]
}

@test "drive:setup: fails when SA key file permissions are not 0600" {
  chmod 644 "$GDRIVE_SA_KEY_FILE"
  run blobs drive:setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"permissions must be exactly 0600"* ]]
  [[ "$output" == *"chmod 600"* ]]
}

@test "drive:setup: fails when SA key file is inside MISE_CONFIG_ROOT" {
  local inside_key="$MISE_CONFIG_ROOT/sa-key.json"
  cp "$GDRIVE_SA_KEY_FILE" "$inside_key"
  chmod 600 "$inside_key"
  export GDRIVE_SA_KEY_FILE="$inside_key"
  run blobs drive:setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"must not be stored inside the project directory"* ]]
}

@test "drive:setup: no-op when remote already configured" {
  echo "test-drive:" > "$RCLONE_REMOTES"
  run blobs drive:setup
  [ "$status" -eq 0 ]
  [[ "$output" == *"already configured"* ]]
}
