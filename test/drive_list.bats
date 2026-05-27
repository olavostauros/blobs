#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_drive_env
}

@test "drive:list: no prefix lists remote root" {
  run blobs drive:list
  [ "$status" -eq 0 ]
  last=$(last_rclone_call)
  [[ "$last" == "lsjson --files-only test-drive:" ]]
}

@test "drive:list: prefix appended to target" {
  run blobs drive:list reports/
  [ "$status" -eq 0 ]
  last=$(last_rclone_call)
  [[ "$last" == "lsjson --files-only test-drive:reports/" ]]
}

@test "drive:list: --recursive passes flag to rclone" {
  run blobs drive:list --recursive
  [ "$status" -eq 0 ]
  last=$(last_rclone_call)
  [[ "$last" == *"--recursive"* ]]
  [[ "$last" == *"--files-only"* ]]
}

@test "drive:list: -r short flag passes --recursive to rclone" {
  run blobs drive:list -r
  [ "$status" -eq 0 ]
  last=$(last_rclone_call)
  [[ "$last" == *"--recursive"* ]]
}

@test "drive:list: --recursive with prefix passes both to rclone" {
  run blobs drive:list --recursive reports/
  [ "$status" -eq 0 ]
  last=$(last_rclone_call)
  [[ "$last" == *"--recursive"* ]]
  [[ "$last" == *"reports/"* ]]
}
