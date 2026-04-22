#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_blobs_env
}

@test "get: to stdout uses mc cat" {
  run blobs get sessions/foo.txt
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == "cat test/test-bucket/sessions/foo.txt" ]]
}

@test "get: to file uses mc cp and reports" {
  run blobs get sessions/foo.txt "$BATS_TEST_TMPDIR/out.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Downloaded: sessions/foo.txt"* ]]
  last=$(last_mc_call)
  [[ "$last" == *"cp"* ]]
  [[ "$last" == *"test/test-bucket/sessions/foo.txt"* ]]
  [[ "$last" == *"out.txt"* ]]
}
