#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_blobs_env
}

@test "list: no prefix lists bucket root" {
  run blobs list
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == "ls test/test-bucket" ]]
}

@test "list: prefix appended to target" {
  run blobs list sessions/
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == "ls test/test-bucket/sessions/" ]]
}

@test "list: --json passes flag to mc" {
  run blobs list --json
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == *"--json"* ]]
}

@test "list: --recursive passes flag to mc" {
  run blobs list --recursive
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == *"--recursive"* ]]
}

@test "list: -r short flag passes --recursive to mc" {
  run blobs list -r
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == *"--recursive"* ]]
}

@test "list: --recursive with prefix passes both to mc" {
  run blobs list --recursive backups/
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == *"--recursive"* ]]
  [[ "$last" == *"backups/"* ]]
}

@test "list: --json and --recursive compose" {
  run blobs list --json --recursive backups/
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == "ls --json --recursive test/test-bucket/backups/" ]]
}

@test "list: ignores inherited optional usage env" {
  export usage_prefix="stale/"
  export usage_json="true"
  export usage_recursive="true"

  run blobs list
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == "ls test/test-bucket" ]]
}
