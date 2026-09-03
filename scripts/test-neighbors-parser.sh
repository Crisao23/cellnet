#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
FIXTURE_DEVICE="$ROOT_DIR/tests/fixtures/qmi-neighbors-indented.txt"
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/cellnet-neighbors.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' 0 1 2 15
FIXTURE_QMICLI="$TMP_ROOT/qmicli"

printf '%s\n' '#!/bin/sh' 'cat "$CELLNET_NEIGHBOR_FIXTURE"' > "$FIXTURE_QMICLI"
chmod +x "$FIXTURE_QMICLI"

run_fixture() {
    CELLNET_NEIGHBOR_FIXTURE="$FIXTURE_DEVICE" \
    CELLNET_QMICLI="$FIXTURE_QMICLI" \
    CELLNET_QMI_DEVICE="$FIXTURE_DEVICE" \
        sh "$ROOT_DIR/cellnet" "$@"
}

run_fixture neighbors csv > "$TMP_ROOT/neighbors.csv"
grep -q '^serving,LTE,00101,100,25601,10,9410,B28,-10.0,-70.0,-40.0$' "$TMP_ROOT/neighbors.csv"
grep -q '^neighbor,LTE,n/a,n/a,n/a,20,9410,B28,-12.0,-75.0,-45.0$' "$TMP_ROOT/neighbors.csv"
grep -q '^neighbor,LTE,n/a,n/a,n/a,30,1700,B3,-14.0,-80.0,-50.0$' "$TMP_ROOT/neighbors.csv"
[ "$(wc -l < "$TMP_ROOT/neighbors.csv" | tr -d ' ')" -eq 4 ]

run_fixture neighbors json > "$TMP_ROOT/neighbors.json"
grep -q '"type":"serving"' "$TMP_ROOT/neighbors.json"
grep -q '"pci":"30"' "$TMP_ROOT/neighbors.json"

echo "Neighbor parser fixture passed."
