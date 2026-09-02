# Troubleshooting

## Test follows the wrong connection
Confirm the current script still contains:

```text
--intf "$WWAN_IF"
```

and that `WWAN_IF` is `wwan0`.

## First test fails
The current baseline includes a 3-second warm-up plus one retry. Capture the exact `Reason:` and selected server if failures continue.

## Server is blank
Current versions should show either a detected URL or:

```text
automatic / not reported by ui-speed
```

## High latency with good RF
Good RSRP/SNR does not guarantee low latency. Possible causes include cell load/scheduler, mobile core, roaming path, peering/routing or the selected test server.

## LTE CA shows `deactivated`
SCells can deactivate rapidly after traffic. Prefer the `CA / RF BY PHASE` counters.

## `cells` or `tower-id` shows `n/a`
The normalized parser only accepts explicitly labeled QMI fields. Firmware, modem state and qmicli output can vary. Compare with raw `cellnet cell`, `cellnet radio` and `cellnet rf` output. Do not assume an NR PCI, NCI or band from a nearby value unless the modem labels it unambiguously.

## eNodeB or sector is `n/a`
Automatic decomposition requires a decimal LTE ECI/global cell ID. Hexadecimal, missing or differently formatted identifiers are left unchanged rather than guessed.

When the serving RAT is UMTS/WCDMA, LTE TAC, ECI, eNodeB, sector, PCI, EARFCN and band intentionally remain `n/a`. Use the raw `cell` and `radio` commands for UMTS Cell ID, LAC, UARFCN and scrambling-code details.

## `watch` reports changes involving `n/a`
A transition between a value and `n/a` may reflect a temporarily missing modem response rather than an actual handover. Use a longer observation and compare ECI, PCI and EARFCN together.

## QMI LOC GNSS timeout
A timeout can be caused by lack of satellite visibility indoors. It does not by itself prove GNSS hardware is absent.

GNSS commands are not part of v9.6.0. OpenCellID tower coordinates and manually supplied device coordinates are not GNSS data obtained from the modem.

## OpenCellID lookup fails
Confirm that `OPENCELLID_API_KEY`, `CELLNET_LATITUDE` and `CELLNET_LONGITUDE` are set, that `curl` or `wget` is available, and that the serving RAT is LTE with decimal MCC, MNC, TAC and ECI values. OpenCellID access and quotas depend on its current API policy. A missing match does not mean that the serving cell is invalid.

Exit code `3` means that OpenCellID responded but did not provide usable coordinates. The command includes the sanitized provider message so a missing cell can be distinguished from authentication, quota and response-format problems. The on-device test records this condition as `SKIP`, because absence from a third-party crowdsourced database is not a local modem failure.

## SSH disconnects
For long diagnostics:

```sh
nohup cellnet speedtest > /tmp/log/cellnet-speedtest.log 2>&1 &
```

Also compare boot ID before/after to distinguish an SSH-path issue from a device reboot.
