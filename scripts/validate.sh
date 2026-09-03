#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

echo "Checking POSIX shell syntax..."
sh -n cellnet
sh -n bin/cellnet
sh -n install.sh
sh -n scripts/test-device.sh
sh -n scripts/test-neighbors-parser.sh

echo "Checking executable copies..."
cmp -s cellnet bin/cellnet || {
    echo "ERROR: cellnet and bin/cellnet differ." >&2
    exit 1
}

echo "Checking required commands and safety invariants..."
for command_name in \
    tim vivo auto status full signal cell radio rf cells tower-id neighbors neighbors-csv \
    neighbors-json tower-export \
    tower-lookup observe-cells tower-assess tower-assess-speed watch stability \
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

echo "Checking normalized neighbor parser..."
sh scripts/test-neighbors-parser.sh

if command -v shellcheck >/dev/null 2>&1; then
    echo "Running ShellCheck..."
    # Fail on actionable warnings and errors. Informational/style diagnostics
    # remain visible when ShellCheck is run manually but do not make CI depend
    # on the informational rule set shipped by a particular distro release.
    shellcheck --severity=warning -x \
        cellnet bin/cellnet install.sh scripts/validate.sh scripts/test-device.sh
else
    echo "ShellCheck not found; skipping optional local lint." >&2
fi

echo "Validation passed."
