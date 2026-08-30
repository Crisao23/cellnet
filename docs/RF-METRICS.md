# RF Metrics

## LTE / NR RSRP
Signal-strength metric. Stronger is generally better, but RSRP alone does not predict throughput.

## RSRQ
Quality metric affected by interference and loading.

## SNR / SINR
Often more useful than raw RSRP for physical placement/alignment. A stable higher SNR can be more valuable than a slightly stronger RSRP.

## LTE Carrier Aggregation
The modem can quickly deactivate LTE SCells after traffic ends, so checking only after a speed test can miss CA activity. `cellnet` samples CA while the test is running.

An important limitation:

```text
UL CA ativa
```

describes LTE CA SCells only. It must not be interpreted as a direct indicator of NR uplink usage.

## 5G NSA
LTE remains the anchor while NR contributes capacity. High throughput may occur even when LTE SCells are not active in the sampled moments.

## Cell identifiers
TAC, ECI/global cell ID, PCI, EARFCN and NR identifiers are printed only when matching QMI labels are available. `n/a` means the modem response did not expose a field in a recognized form; it does not prove the radio network lacks that value.

For a decimal LTE ECI, `cellnet` reports a calculated eNodeB ID (`ECI >> 8`) and sector ID (`ECI & 255`). This is the common LTE ECI layout, not a universal operator guarantee.

`tower-id` prepares these values for external correlation but does not infer tower coordinates. No GNSS position is collected by the Phase 1 commands.

## Stability statistics
`stability` uses the numeric portion of modem-reported RF measurements. Average, minimum, maximum and range are descriptive statistics over the available samples; missing readings are excluded. Cell-change counters compare consecutive samples and do not generate network traffic.

## Practical tuning
When repositioning the U5G:

1. watch NR SNR stability;
2. watch LTE anchor SNR;
3. note PCI/EARFCN/NR-ARFCN changes;
4. use `cellnet watch` or `cellnet stability` before consuming data;
5. use a short throughput test only to validate promising positions.
