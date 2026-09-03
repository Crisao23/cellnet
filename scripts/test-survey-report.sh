#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
FIXTURE="$ROOT_DIR/tests/fixtures/cells-observations.csv"
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/cellnet-survey-report.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' 0 1 2 15

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

mkdir "$TMP_ROOT/a" "$TMP_ROOT/b"
cp "$FIXTURE" "$TMP_ROOT/a/cells.csv"
sed 's/,00101,lte,100,/,00102,lte,200,/; s/,25601,/,30001,/' \
    "$FIXTURE" > "$TMP_ROOT/b/cells.csv"

COMPARE_OUTPUT=$(
    CELLNET_QMICLI=true \
    CELLNET_QMI_DEVICE="$FIXTURE" \
        sh "$ROOT_DIR/cellnet" survey-compare "$TMP_ROOT/a" "$TMP_ROOT/b"
)
echo "$COMPARE_OUTPUT" | grep -q '^Same PLMN:[[:space:]]*no$'
echo "$COMPARE_OUTPUT" | grep -q '^Direct RF comparison:[[:space:]]*no$'
echo "$COMPARE_OUTPUT" | grep -q '^CAUTION: RF deltas are contextual'

echo "Survey report fixture passed."
