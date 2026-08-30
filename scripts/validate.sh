#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

echo "Checking POSIX shell syntax..."
sh -n cellnet
sh -n bin/cellnet
sh -n install.sh

echo "Checking executable copies..."
cmp -s cellnet bin/cellnet || {
    echo "ERROR: cellnet and bin/cellnet differ." >&2
    exit 1
}

echo "Checking required commands and safety invariants..."
for command_name in \
    tim vivo auto status full signal cell radio rf cells tower-id watch stability \
    preferences scan snapshot \
    compare speedtest speedtest-fixed compare-speed compare-speed-fixed
do
    grep -q "^[[:space:]]*$command_name)" cellnet || {
        echo "ERROR: required command is missing: $command_name" >&2
        exit 1
    }
done

grep -q '^speedtest_current()' cellnet || {
    echo "ERROR: speedtest_current() is missing." >&2
    exit 1
}
grep -q '^compare_speed()' cellnet || {
    echo "ERROR: compare_speed() is missing." >&2
    exit 1
}
# The literal source expression is the invariant, not the current variable value.
# shellcheck disable=SC2016
grep -Fq -- '--intf "$WWAN_IF"' cellnet || {
    echo "ERROR: ui-speed interface binding is missing." >&2
    exit 1
}
grep -Fq -- '-d both' cellnet || {
    echo "ERROR: bidirectional speed-test mode is missing." >&2
    exit 1
}

if command -v shellcheck >/dev/null 2>&1; then
    echo "Running ShellCheck..."
    shellcheck -x cellnet bin/cellnet install.sh scripts/validate.sh
else
    echo "ShellCheck not found; skipping optional local lint." >&2
fi

echo "Validation passed."
