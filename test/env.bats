#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_blobs_env
}

@test "env: fails when B2_ALIAS not set" {
  unset B2_ALIAS
  run blobs list
  [ "$status" -ne 0 ]
  [[ "$output" == *"B2_ALIAS is not set"* ]]
}

@test "env: fails when B2_BUCKET not set" {
  unset B2_BUCKET
  run blobs list
  [ "$status" -ne 0 ]
  [[ "$output" == *"B2_BUCKET is not set"* ]]
}

@test "env: fails when mc alias not configured" {
  clear_mc_alias
  run blobs list
  [ "$status" -ne 0 ]
  [[ "$output" == *"mc alias 'test' not configured"* ]]
  [[ "$output" == *"blobs setup"* ]]
}
