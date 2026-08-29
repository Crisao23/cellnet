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
