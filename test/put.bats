#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_blobs_env
}

@test "put: uploads file with mc cp" {
  echo "hello" > "$BATS_TEST_TMPDIR/hello.txt"
  run blobs put sessions/hello.txt "$BATS_TEST_TMPDIR/hello.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Uploaded: sessions/hello.txt"* ]]
  last=$(last_mc_call)
  [[ "$last" == *"cp"* ]]
  [[ "$last" == *"hello.txt"* ]]
  [[ "$last" == *"test/test-bucket/sessions/hello.txt"* ]]
}

@test "put: stdin when file omitted uses mc pipe" {
  run bash -c 'echo streamed | blobs put sessions/from-stdin'
  [ "$status" -eq 0 ]
  last=$(last_mc_call)
  [[ "$last" == *"pipe"* ]]
  [[ "$last" == *"test/test-bucket/sessions/from-stdin"* ]]
}

@test "put: fails for missing local file" {
  run blobs put sessions/nope.txt "$BATS_TEST_TMPDIR/nope.txt"
  [ "$status" -ne 0 ]
  [[ "$output" == *"File not found"* ]]
}
