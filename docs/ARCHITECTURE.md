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

### Radio-intelligence sampler
The `cells`, `tower-id`, `watch` and `stability` commands use a separate foreground sampler. It combines read-only responses from serving-system, signal, system, cell-location, RF-band and LTE-CA QMI queries into a positional internal record. Unsupported or ambiguous fields remain `n/a`.

The layers are intentionally distinct:

1. modem-derived values are labels returned by QMI;
2. LTE eNodeB/sector values are calculated from a decimal ECI using the common LTE layout;
3. optional tower coordinates are external OpenCellID correlations;
4. device coordinates are explicit user input and must be independently validated.

External tower coordinates are optionally correlated through OpenCellID using LTE MCC, MNC, TAC and ECI. Device coordinates remain explicit user input; neither value is represented as a modem GNSS fix. Direct cell locking is not implemented.

### Internal result record
Speed-test results are serialized into a positional pipe-delimited record. This is a compatibility boundary: changing field order or field count requires updating every parser/consumer.

The radio-intelligence record is independent from the speed-test result record, so diagnostics do not alter throughput parsing.

## Design principles

1. Preserve the latest known-good baseline.
2. Make incremental changes only.
3. Do not introduce persistent RAT/band forcing into normal carrier selection.
4. Run `sh -n` before release.
5. Keep all mobile throughput tests bound to `wwan0`.
6. Prefer low-data diagnostics for routine tuning.
7. Keep both automatic-server and fixed-server modes available.
