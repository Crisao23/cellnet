# Troubleshooting

## Test follows the wrong connection
Confirm the current script still contains:

```text
--intf "$WWAN_IF"
```

and that `WWAN_IF` is `wwan0`.

## First test fails
The current baseline includes a 3-second warm-up plus one retry. Capture the exact `Motivo:` and selected server if failures continue.

## Server is blank
Current versions should show either a detected URL or:

```text
automatico / nao informado pelo ui-speed
```

## High latency with good RF
Good RSRP/SNR does not guarantee low latency. Possible causes include cell load/scheduler, mobile core, roaming path, peering/routing or the selected test server.

## LTE CA shows `deactivated`
SCells can deactivate rapidly after traffic. Prefer the `CA / RF POR FASE` counters.

## QMI LOC GNSS timeout
A timeout can be caused by lack of satellite visibility indoors. It does not by itself prove GNSS hardware is absent.

## SSH disconnects
For long diagnostics:

```sh
nohup cellnet speedtest > /tmp/log/cellnet-speedtest.log 2>&1 &
```

Also compare boot ID before/after to distinguish an SSH-path issue from a device reboot.
