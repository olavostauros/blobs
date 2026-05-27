#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_drive_env
}

@test "drive:get: to stdout uses rclone cat" {
  run blobs drive:get reports/foo.csv
  [ "$status" -eq 0 ]
  last=$(last_rclone_call)
  [[ "$last" == "cat test-drive:reports/foo.csv" ]]
}

@test "drive:get: to file uses rclone copyto and reports" {
  run blobs drive:get reports/foo.csv "$BATS_TEST_TMPDIR/out.csv"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Downloaded: reports/foo.csv"* ]]
  last=$(last_rclone_call)
  [[ "$last" == *"copyto"* ]]
  [[ "$last" == *"test-drive:reports/foo.csv"* ]]
  [[ "$last" == *"out.csv"* ]]
}

@test "drive:get: fails when key argument is missing" {
  run blobs drive:get
  [ "$status" -ne 0 ]
}

@test "drive:get: --id to stdout uses rclone backend copyid" {
  run blobs drive:get --id 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms
  [ "$status" -eq 0 ]
  last=$(last_rclone_call)
  [[ "$last" == "backend copyid test-drive: 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms "* ]]
}

@test "drive:get: --id to file uses rclone backend copyid and reports" {
  run blobs drive:get --id 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms "$BATS_TEST_TMPDIR/out.pdf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Downloaded: 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms"* ]]
  last=$(last_rclone_call)
  [[ "$last" == "backend copyid test-drive: 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms $BATS_TEST_TMPDIR/out.pdf" ]]
}
