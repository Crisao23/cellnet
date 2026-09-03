# Development and Regression Policy

The project uses a **stable-baseline, incremental-change** model.

## Baseline rule
Never reconstruct the script from fragments for a feature change. Start from the latest validated baseline.

## Commands that must remain available

```text
tim
vivo
auto
status
full
signal
cell
radio
rf
cells
tower-id
watch
stability
preferences
scan
snapshot
compare
speedtest
speedtest-fixed
compare-speed
compare-speed-fixed
```

## Mandatory checks

```sh
sh scripts/validate.sh
```

Also verify:
- `ui-speed` remains bound to `wwan0`;
- throughput still uses `-d both`;
- automatic server selection remains default;
- fixed-server commands remain available;
- normal carrier selection does not gain RAT filters;
- `speedtest_current()` and `compare_speed()` exist;
- internal result-record field count/indexes are consistent.
- radio-intelligence queries remain read-only and do not invoke `ui-speed`;
- unknown NR identifiers remain `n/a` rather than inferred.

## Dangerous regression

Do not add these to normal carrier-switching paths:

```text
5gnr,manual=<PLMN>
lte,manual=<PLMN>
```

## Internal record schema
The speed-test record is positional. When adding fields:

1. document the schema change;
2. count `printf` placeholders;
3. update `print_speed_record`;
4. update `field_from_record` consumers;
5. test success, retry and error paths.

The radio-intelligence sampler uses a separate 28-field record consumed by `record_field()`. Field 28 records the serving RAT so LTE identifiers are emitted only for an LTE serving cell. Keep it independent from the speed-test record. If it changes, update `cells_summary()`, `tower_id()`, `tower_export()`, `tower_lookup()`, `observe_cells()`, `watch_radio()`, `stability_summary()` and this documentation together.

## Suggested checks

```sh
sh -n cellnet
grep -n '^speedtest_current()' cellnet
grep -n '^compare_speed()' cellnet
grep -n -- '--intf "$WWAN_IF"' cellnet
grep -n -- '-d both' cellnet
```

The validation script checks syntax, synchronized executable copies, required commands, safety invariants, and ShellCheck when it is installed. The included GitHub Actions workflow installs ShellCheck and runs the same script.

## On-device integration test

Copy `scripts/test-device.sh` to the device and run it against `/tmp/log/cellnet/cellnet`:

```sh
chmod +x /tmp/log/cellnet/cellnet /tmp/log/cellnet/test-device.sh
/tmp/log/cellnet/test-device.sh
```

Repository validation runs ShellCheck at `warning` severity. This keeps errors and actionable warnings blocking while avoiding CI failures caused only by informational rules added or reclassified between distribution-provided ShellCheck versions. Fix informational findings when they identify real ambiguity; do not suppress warnings to bypass a genuine defect.

The normalized neighbor parser is based on the tested `qmicli --nas-get-cell-location-info` sections `Intrafrequency LTE Info` and `Interfrequency LTE Info`. Preserve the raw format as the compatibility and troubleshooting path. Never synthesize a neighbor ECI from PCI or EARFCN.

`CELLNET_QMI_DEVICE`, `CELLNET_QMICLI` and `CELLNET_WWAN_IF` may override hardware paths for isolated fixtures. Production behavior retains `/dev/wwan0qmi0`, `qmicli` and `wwan0` as defaults.

The default is read-only. Optional modes are `--scan`, `--carrier`, `--speed`, and `--all`. Carrier mode restores automatic selection during cleanup. Speed mode consumes cellular data. Each test captures output, validates an expected marker and writes a PASS/FAIL/SKIP summary under `/tmp/log/cellnet/cellnet-test-*`.

## Language policy

Source code comments, help text, diagnostic messages, internal status labels and repository documentation are maintained in English.

New contributions should not introduce user-facing strings or source comments in another language unless localization support is intentionally added as a separate feature.
