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

## Practical tuning
When repositioning the U5G:

1. watch NR SNR stability;
2. watch LTE anchor SNR;
3. note PCI/EARFCN/NR-ARFCN changes;
4. use a short throughput test only to validate promising positions.
