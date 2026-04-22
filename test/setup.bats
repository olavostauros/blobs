#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  load test_helper
  setup_blobs_env
  clear_mc_alias  # setup task creates the alias; start from not-configured
}

@test "setup: configures mc alias when all env vars present" {
  export B2_ENDPOINT="https://s3.example.com"
  export B2_KEY_ID="keyid"
  export B2_APPLICATION_KEY="appkey"
  run blobs setup
  [ "$status" -eq 0 ]
  [[ "$output" == *"Blob storage configured"* ]]
  calls=$(all_mc_calls)
  [[ "$calls" == *"alias set test https://s3.example.com keyid appkey --api s3v4"* ]]
}

@test "setup: adds https:// when endpoint missing scheme" {
  export B2_ENDPOINT="s3.example.com"
  export B2_KEY_ID="keyid"
  export B2_APPLICATION_KEY="appkey"
  run blobs setup
  [ "$status" -eq 0 ]
  calls=$(all_mc_calls)
  [[ "$calls" == *"https://s3.example.com"* ]]
}

@test "setup: fails without B2_ALIAS" {
  unset B2_ALIAS
  export B2_ENDPOINT="https://s3.example.com"
  export B2_KEY_ID="keyid"
  export B2_APPLICATION_KEY="appkey"
  run blobs setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"B2_ALIAS"* ]]
}

@test "setup: fails without B2_ENDPOINT" {
  unset B2_ENDPOINT
  export B2_KEY_ID="keyid"
  export B2_APPLICATION_KEY="appkey"
  run blobs setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"B2_ENDPOINT"* ]]
}

@test "setup: fails without B2_KEY_ID" {
  export B2_ENDPOINT="https://s3.example.com"
  unset B2_KEY_ID
  export B2_APPLICATION_KEY="appkey"
  run blobs setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"B2_KEY_ID"* ]]
}

@test "setup: fails without B2_APPLICATION_KEY" {
  export B2_ENDPOINT="https://s3.example.com"
  export B2_KEY_ID="keyid"
  unset B2_APPLICATION_KEY
  run blobs setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"B2_APPLICATION_KEY"* ]]
}

@test "setup: reports multiple missing vars together" {
  unset B2_ENDPOINT B2_KEY_ID B2_APPLICATION_KEY
  run blobs setup
  [ "$status" -ne 0 ]
  [[ "$output" == *"B2_ENDPOINT"* ]]
  [[ "$output" == *"B2_KEY_ID"* ]]
  [[ "$output" == *"B2_APPLICATION_KEY"* ]]
}

@test "setup: no-op when alias already configured" {
  echo "test" > "$MC_ALIAS_LIST"
  export B2_ENDPOINT="https://s3.example.com"
  export B2_KEY_ID="keyid"
  export B2_APPLICATION_KEY="appkey"
  run blobs setup
  [ "$status" -eq 0 ]
  [[ "$output" == *"already configured"* ]]
}
