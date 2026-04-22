#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_blobs_env
}

@test "delete: calls mc rm with full target key" {
  run blobs delete sessions/old.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"Deleted: sessions/old.txt"* ]]
  last=$(last_mc_call)
  [[ "$last" == "rm test/test-bucket/sessions/old.txt" ]]
}
