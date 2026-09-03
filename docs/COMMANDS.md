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

### `cellnet neighbors [raw|table|csv|json]`
The default `raw` format preserves the complete read-only QMI cell-location response. `table`, `csv` and `json` normalize the serving and neighboring LTE observations exposed by the tested firmware, including PCI, EARFCN, band, RSRQ, RSRP and RSSI.

The QMI response provides ECI only for the serving LTE cell. Neighbor observations therefore retain `eci=n/a`; PCI and EARFCN must not be treated as a globally unique tower identity. `neighbors-csv` and `neighbors-json` are aliases for the corresponding structured formats.

### `cellnet tower-export [json|csv]`
Exports the normalized serving-cell identity without performing an Internet lookup. The default format is JSON; CSV is suitable for observation logs and external analysis.

### `cellnet tower-lookup [latitude longitude]`
Queries the OpenCellID `/cell/get` endpoint for the current LTE MCC, MNC, TAC and ECI. The API key is read from `OPENCELLID_API_KEY`. Device coordinates may be passed as arguments or through `CELLNET_LATITUDE` and `CELLNET_LONGITUDE`. The result includes approximate distance, initial bearing, OpenCellID range/sample metadata and a conservative correlation-confidence label.

### `cellnet observe-cells [seconds]`
Emits timestamped serving-cell and RF samples as CSV every three seconds. It is read-only and suitable for recording handovers or antenna-orientation tests.

### `cellnet tower-assess latitude longitude [seconds]`
Runs `tower-lookup` followed by the existing read-only stability summary. It compares proximity with actual RF stability rather than treating the closest reported cell as automatically best.

### `cellnet tower-assess-speed latitude longitude [seconds]`
Adds the existing interface-bound bidirectional speed test to the tower assessment. This command consumes cellular data.

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
