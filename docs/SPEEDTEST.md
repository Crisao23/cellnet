# Speed Testing

## Cellular interface binding

All cellular throughput tests use:

```sh
--intf wwan0
```

This prevents accidental measurement of a fixed/LAN path.

## Automatic server selection

Default:

```sh
cellnet speedtest
```

`ui-speed` selects the endpoint automatically.

## Fixed server

```sh
cellnet speedtest-fixed
```

Configured endpoint:

```text
http://103.14.27.177:80
```

Use fixed mode when endpoint consistency is more important than best-server selection.

## Warm-up

Current behavior:

```text
warm-up: 3 s
post-warm-up wait: 2 s
```

The warm-up was introduced after repeated first-attempt `ui-speed` failures.

## Retry
The script preserves a partial record when possible and retries once.

A normal `cellnet speedtest` does **not** reconnect or change PLMN.

## RF/CA sampling
Current interval:

```text
3 s
```

Samples are classified as setup/download/upload/done according to `ui-speed` state.

## Data quota
Speed tests can consume hundreds of megabytes on fast 5G. Prefer RF-only commands for routine diagnostics.
