# Architecture

`cellnet` is a single POSIX shell program for the constrained userspace of the U5G Max Outdoor.

## Layers

### QMI
`qmicli` talks to `/dev/wwan0qmi0` and supplies registration, PLMN selection, signal, serving-cell, LTE CA and preference information.

### Cellular routing
Throughput tests are explicitly bound to `wwan0`, because the device may also have a LAN/default route.

### `ui-speed`
`ui-speed` provides throughput testing. The script observes JSON states including:

```text
state 3 -> download
state 4 -> upload
state 5 -> successful completion
state 7 -> failed/partial completion
```

### RF/CA monitor
A background sampler collects LTE/NR metrics and LTE CA state during throughput testing.

Current interval: `3 seconds`.

### Internal result record
Speed-test results are serialized into a positional pipe-delimited record. This is a compatibility boundary: changing field order or field count requires updating every parser/consumer.

## Design principles

1. Preserve the latest known-good baseline.
2. Make incremental changes only.
3. Do not introduce persistent RAT/band forcing into normal carrier selection.
4. Run `sh -n` before release.
5. Keep all mobile throughput tests bound to `wwan0`.
6. Prefer low-data diagnostics for routine tuning.
7. Keep both automatic-server and fixed-server modes available.
