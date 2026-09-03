#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
FIXTURE="$ROOT_DIR/tests/fixtures/cells-observations.csv"

OUTPUT=$(
    CELLNET_QMICLI=true \
    CELLNET_QMI_DEVICE="$FIXTURE" \
        sh "$ROOT_DIR/cellnet" survey-report "$FIXTURE"
)

echo "$OUTPUT" | grep -q '^Samples:[[:space:]]*3$'
echo "$OUTPUT" | grep -q '^Unique cell identities:[[:space:]]*2$'
echo "$OUTPUT" | grep -q '^Cell identity changes:[[:space:]]*1$'
echo "$OUTPUT" | grep -q '^LTE RSRP:[[:space:]]*avg=-74.00 min=-80.00 max=-70.00 samples=3$'
echo "$OUTPUT" | grep -q '^NR RSRP:[[:space:]]*avg=-67.00 min=-68.00 max=-66.00 samples=2$'

echo "Survey report fixture passed."
