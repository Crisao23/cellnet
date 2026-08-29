# Installation

## Requirements

The tested environment provides:

- POSIX/BusyBox `sh`
- `qmicli`
- QMI proxy support
- `ui-speed`
- `/dev/wwan0qmi0`
- `wwan0`
- standard BusyBox tools (`awk`, `sed`, `grep`, `tail`, `sleep`)

Quick checks:

```sh
command -v qmicli
command -v ui-speed
ls -l /dev/wwan0qmi0
ip link show wwan0
```

## Recommended location

On the tested U5G Max Outdoor, `/usr/bin` should not be assumed persistent. The working location used by this project is:

```sh
mkdir -p /tmp/log/scripts
cp cellnet /tmp/log/scripts/cellnet
chmod +x /tmp/log/scripts/cellnet
export PATH="$PATH:/tmp/log/scripts"
```

Validate:

```sh
sh -n /tmp/log/scripts/cellnet
cellnet status
```

## Upgrade and rollback

Keep a known-good copy before replacing the script:

```sh
cp /tmp/log/scripts/cellnet /tmp/log/scripts/cellnet.backup
cp cellnet /tmp/log/scripts/cellnet
chmod +x /tmp/log/scripts/cellnet
sh -n /tmp/log/scripts/cellnet
```

Smoke test:

```sh
cellnet status
cellnet rf
cellnet --help
```

Rollback:

```sh
cp /tmp/log/scripts/cellnet.backup /tmp/log/scripts/cellnet
chmod +x /tmp/log/scripts/cellnet
```
