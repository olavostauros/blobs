#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_drive_env
}

@test "drive:_env: fails when GDRIVE_REMOTE not set" {
  unset GDRIVE_REMOTE
  run blobs drive:list
  [ "$status" -ne 0 ]
  [[ "$output" == *"GDRIVE_REMOTE is not set"* ]]
}

@test "drive:_env: fails when GDRIVE_SA_KEY_FILE not set" {
  unset GDRIVE_SA_KEY_FILE
  run blobs drive:list
  [ "$status" -ne 0 ]
  [[ "$output" == *"GDRIVE_SA_KEY_FILE is not set"* ]]
}

@test "drive:_env: fails when SA key file does not exist" {
  export GDRIVE_SA_KEY_FILE="$BATS_TEST_TMPDIR/no-such-file.json"
  run blobs drive:list
  [ "$status" -ne 0 ]
  [[ "$output" == *"SA key file not found"* ]]
  [[ "$output" == *"drive:setup"* ]]
}

@test "drive:_env: fails when rclone remote not configured" {
  clear_drive_remote
  run blobs drive:list
  [ "$status" -ne 0 ]
  [[ "$output" == *"rclone remote 'test-drive' not configured"* ]]
  [[ "$output" == *"drive:setup"* ]]
}
