# blobs

**Object storage put/get/list/delete.** Thin wrapper over [`mc`](https://min.io/docs/minio/linux/reference/minio-mc.html) for S3-compatible buckets (Backblaze B2 is the reference backend).

```
blobs put <key> <file>       Upload
blobs get <key> [dest]       Download (default: stdout)
blobs list [prefix]          List objects
blobs delete <key>           Remove an object
blobs welcome                Status overview
blobs setup                  Configure the mc alias (one-time)
```

## Install

```bash
shiv install blobs
```

## Configure

blobs is driven entirely by environment variables — it has no config file and no identity concept. The user provides the alias name, bucket, and B2 credentials.

| Variable             | Required by        | Purpose                                                        |
| -------------------- | ------------------ | -------------------------------------------------------------- |
| `B2_ALIAS`           | setup + ops        | Name blobs/mc will use for this configuration (your choice)    |
| `B2_BUCKET`          | ops                | Bucket name                                                    |
| `B2_ENDPOINT`        | setup              | B2 S3-compatible endpoint URL                                  |
| `B2_KEY_ID`          | setup              | B2 application key ID                                          |
| `B2_APPLICATION_KEY` | setup              | B2 application key secret                                      |

One-time setup:

```bash
export B2_ALIAS=myalias
export B2_ENDPOINT=https://s3.us-east-005.backblazeb2.com
export B2_KEY_ID=...
export B2_APPLICATION_KEY=...
blobs setup
```

Then, for daily use:

```bash
export B2_ALIAS=myalias
export B2_BUCKET=my-bucket
blobs put notes/hello.txt ./hello.txt
blobs list notes/
blobs get notes/hello.txt
blobs delete notes/hello.txt
```

## Multiple accounts / buckets

blobs doesn't manage profiles — the environment does. For a second account, use different values:

```bash
# Work account
B2_ALIAS=work B2_BUCKET=work-logs blobs list

# Personal account
B2_ALIAS=personal B2_BUCKET=backups blobs list
```

Each unique `B2_ALIAS` maps to its own `mc` alias configuration, set up once via `blobs setup`.

## How it works

Internally, blobs calls `mc` (the MinIO Client), which stores aliases in `~/.mc/config.json`. Users of blobs don't interact with `mc` directly — it's an implementation detail. `blobs setup` is the one-time shim that calls `mc alias set`; every other command operates via `$B2_ALIAS/$B2_BUCKET/$KEY` targets.

## Development

```bash
mise install      # installs mc, bats, jq, etc.
mise run test     # runs the BATS suite
```

Tests shadow `mc` on `$PATH` with a recording mock — no real B2 traffic is needed to run the suite.

## License

MIT
