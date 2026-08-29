# cellnet

`cellnet` is a POSIX shell utility for diagnostics, carrier selection, RF inspection and controlled throughput testing on the **Ubiquiti UniFi U5G Max Outdoor** through the modem QMI interface.

Current baseline: **v9.3-stable-sampling-3s**

> This is an independent project and is not affiliated with or endorsed by Ubiquiti.

## Highlights

- TIM / Vivo manual PLMN selection and return to automatic selection.
- LTE / 5G NSA registration and signal diagnostics.
- Serving-cell, PCI, TAC, EARFCN and RF inspection.
- LTE Carrier Aggregation visibility.
- Diagnostic snapshots and TIM × Vivo comparisons.
- Cellular speed tests forced through `wwan0`.
- Automatic speed-test server selection by default.
- Fixed-server mode for controlled comparisons.
- Warm-up, retry and partial-result handling.
- RF / LTE-CA sampling during throughput tests.
- Separate download/upload RF and CA observations.
- Conservative behavior: normal carrier switching does **not** force LTE/5G RAT modes.

## Important safety rule

Normal carrier switching uses **PLMN only**.

The script deliberately avoids:

```text
5gnr,manual=...
lte,manual=...
```

Those forms can alter persistent RAT/mode preference on the modem.

## Tested environment

```text
Device:             Ubiquiti U5G Max Outdoor
Cellular interface: wwan0
QMI device:         /dev/wwan0qmi0
qmicli:             1.38.x
Firmware family:    UniFi U5G Max Outdoor 7.5.x
Shell:              BusyBox / POSIX sh
```

## Quick installation

```sh
mkdir -p /tmp/log/scripts
cp cellnet /tmp/log/scripts/cellnet
chmod +x /tmp/log/scripts/cellnet
export PATH="$PATH:/tmp/log/scripts"
sh -n /tmp/log/scripts/cellnet
```

Then:

```sh
cellnet status
cellnet rf
cellnet speedtest
```

## Commands

| Command | Purpose |
|---|---|
| `cellnet tim` | Select TIM PLMN manually |
| `cellnet vivo` | Select Vivo PLMN manually |
| `cellnet auto` | Return to automatic network selection |
| `cellnet status` | Short registration/operator status |
| `cellnet full` | Extended network/signal/RF status |
| `cellnet signal` | LTE/5G signal metrics |
| `cellnet cell` | Serving-cell/channel information |
| `cellnet radio` | LTE/5G NSA/SA information |
| `cellnet rf` | Bands, LTE CA, cell and signal summary |
| `cellnet preferences` | Current modem system-selection preferences |
| `cellnet scan` | Scan visible operators |
| `cellnet snapshot [name]` | Capture a diagnostic snapshot |
| `cellnet compare` | TIM → Vivo RF comparison |
| `cellnet speedtest [seconds]` | Mobile speed test, automatic server |
| `cellnet speedtest-fixed [seconds]` | Mobile speed test, configured fixed server |
| `cellnet compare-speed [seconds]` | TIM × Vivo performance comparison, automatic servers |
| `cellnet compare-speed-fixed [seconds]` | TIM × Vivo comparison using the same fixed server |

See [Command Reference](docs/COMMANDS.md).

## Speed-test behavior

All throughput tests are bound to:

```text
wwan0
```

and use both directions:

```text
-d both
```

This prevents a test from following a LAN/fixed-broadband default route.

The default:

```sh
cellnet speedtest
```

lets `ui-speed` select a server automatically.

The diagnostic fixed-server mode remains available:

```sh
cellnet speedtest-fixed
```

Current fixed endpoint:

```text
http://103.14.27.177:80
```

## RF sampling

The current baseline samples RF / LTE CA every **3 seconds** during the measured speed test and classifies samples by `ui-speed` phase:

```text
state=3 -> download
state=4 -> upload
```

`UL CA ativa` refers specifically to LTE Carrier Aggregation SCells; it does not directly indicate NR uplink use.

## Data usage

5G speed tests can consume substantial mobile quota. Prefer `rf`, `signal`, `cell` and `snapshot` for tuning, and use throughput tests only to validate a change.

## Documentation

- [Installation](docs/INSTALLATION.md)
- [Command Reference](docs/COMMANDS.md)
- [Architecture](docs/ARCHITECTURE.md)
- [RF Metrics](docs/RF-METRICS.md)
- [Speed Testing](docs/SPEEDTEST.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Development and Regression Policy](docs/DEVELOPMENT.md)
- [Contributing](CONTRIBUTING.md)
- [Security](SECURITY.md)
- [Changelog](CHANGELOG.md)

## License

No open-source license is selected automatically. Before publishing the repository, choose the license that matches how you want others to use the code. See [LICENSE-OPTIONS.md](LICENSE-OPTIONS.md).
