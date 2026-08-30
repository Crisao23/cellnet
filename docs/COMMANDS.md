# Command Reference

## Carrier selection

### `cellnet tim`
Select TIM using manual PLMN `72403`.

### `cellnet vivo`
Select Vivo using manual PLMN `72410`.

### `cellnet auto`
Return network selection to automatic.

Normal carrier selection changes PLMN only and does not intentionally force LTE/5G RAT preference.

## Diagnostics

### `cellnet status`
Compact registration/operator status.

### `cellnet full`
Extended network, signal, cell and RF status.

### `cellnet signal`
LTE and 5G signal metrics.

### `cellnet cell`
Serving-cell and channel information.

### `cellnet radio`
Radio availability/status including NSA/SA information exposed by the modem.

### `cellnet rf`
Combined RF view including LTE Carrier Aggregation.

### `cellnet cells`
Shows a normalized serving-cell summary assembled from local QMI queries. It includes PLMN and registration, LTE cell/channel/signal fields, NR fields explicitly exposed by the modem, NSA availability, and LTE CA state. Missing or ambiguous fields are `n/a`.

LTE ECI, eNodeB, sector, PCI, EARFCN and band fields are emitted only when LTE is the serving RAT. A generic 3GPP/UMTS cell ID is never relabeled or decomposed as LTE ECI.

Decimal LTE ECI values are also decomposed using the common LTE layout (`eNodeB = ECI >> 8`, `sector = ECI & 255`). This calculation may depend on operator implementation.

### `cellnet tower-id`
Prints TAC, ECI, calculated eNodeB/sector, PCI, EARFCN and available NR identifiers, plus a compact lookup fingerprint. It does not contact ANATEL, another tower database, or the Internet.

### `cellnet watch [seconds]`
Runs a timestamped, read-only QMI monitor. The default duration is 60 seconds and the polling interval is 3 seconds. It shows LTE/NR RF values, channels, PLMN and active LTE SCells, and reports changes in PLMN, LTE ECI/PCI/EARFCN and available NR ARFCN/PCI fields. Ctrl+C stops the monitor cleanly.

### `cellnet stability [seconds]`
Collects the same low-data local QMI samples for 60 seconds by default. POSIX `awk` calculates average, minimum, maximum and range for available LTE/NR RSRP, RSRQ and SNR samples. The summary also counts cell/channel changes and reports the maximum active LTE SCell count. No speed test is run.

### `cellnet preferences`
Displays current system-selection preferences.

### `cellnet scan`
Scans visible networks. Visibility does not guarantee that the SIM/eSIM is authorized to register.

## Snapshots and comparisons

### `cellnet snapshot [name]`
Captures a diagnostic snapshot.

### `cellnet compare`
Runs the existing TIM → Vivo RF comparison workflow.

## Speed tests

### `cellnet speedtest [seconds]`
Current-network test using automatic server selection.

Default duration: `10` seconds.

Behavior:
- checks NSA state;
- skips redundant stabilization delay when NSA is already active;
- performs a short warm-up;
- forces `ui-speed` through `wwan0`;
- runs download + upload;
- samples RF and LTE CA during the test;
- preserves partial results when possible;
- retries once when needed.

### `cellnet speedtest-fixed [seconds]`
Same workflow using the configured fixed Ubiquiti server.

### `cellnet compare-speed [seconds]`
TIM × Vivo comparison using automatic server selection independently for each operator.

### `cellnet compare-speed-fixed [seconds]`
TIM × Vivo comparison using the same fixed endpoint.

## Help

```sh
cellnet help
cellnet -h
cellnet --help
```
