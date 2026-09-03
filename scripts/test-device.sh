#!/bin/sh

# On-device integration tester for /tmp/log/cellnet/cellnet.
# Default mode is read-only and does not run a network scan or speed tests.

DEVICE_DIR="${CELLNET_DEVICE_DIR:-/tmp/log/cellnet}"
CELLNET_PATH="${CELLNET_BIN:-$DEVICE_DIR/cellnet}"
WATCH_SECONDS="${CELLNET_TEST_WATCH_SECONDS:-9}"
STABILITY_SECONDS="${CELLNET_TEST_STABILITY_SECONDS:-9}"
SPEED_SECONDS="${CELLNET_TEST_SPEED_SECONDS:-10}"
OBSERVE_SECONDS="${CELLNET_TEST_OBSERVE_SECONDS:-6}"

RUN_SCAN=0
RUN_CARRIER=0
RUN_SPEED=0
RESTORE_REQUIRED=0
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

usage() {
    cat <<EOF
Usage: $0 [--scan] [--carrier] [--speed] [--all]

Modes:
  default     Run read-only local diagnostics only.
  --scan      Also run the potentially slow carrier scan.
  --carrier   Also switch auto -> TIM -> Vivo, run RF comparison, then restore auto.
  --speed     Also run current-network automatic and fixed-server speed tests.
              With --carrier, also run both TIM/Vivo speed comparisons.
  --all       Enable scan, carrier switching and every speed test.

Environment overrides:
  CELLNET_DEVICE_DIR              Default: /tmp/log/cellnet
  CELLNET_BIN                     Default: /tmp/log/cellnet/cellnet
  CELLNET_TEST_WATCH_SECONDS      Default: 9
  CELLNET_TEST_STABILITY_SECONDS  Default: 9
  CELLNET_TEST_SPEED_SECONDS      Default: 10
  CELLNET_TEST_OBSERVE_SECONDS    Default: 6
  OPENCELLID_API_KEY              Optional: enables tower-lookup validation
  CELLNET_LATITUDE                Optional device latitude for tower lookup
  CELLNET_LONGITUDE               Optional device longitude for tower lookup

Every command writes a separate log under /tmp/log/cellnet/cellnet-test-<timestamp>-<pid>.
The final process exit code is nonzero when any required test fails.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --scan) RUN_SCAN=1 ;;
        --carrier) RUN_CARRIER=1 ;;
        --speed) RUN_SPEED=1 ;;
        --all)
            RUN_SCAN=1
            RUN_CARRIER=1
            RUN_SPEED=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

case "$WATCH_SECONDS:$STABILITY_SECONDS:$SPEED_SECONDS:$OBSERVE_SECONDS" in
    *[!0-9:]*|0:*|*:0:*|*:0)
        echo "ERROR: test durations must be positive whole seconds." >&2
        exit 2
        ;;
esac

PATH="$DEVICE_DIR:$PATH"
export PATH

TIMESTAMP="$(date '+%Y%m%d-%H%M%S' 2>/dev/null || echo unknown-time)"
RESULT_DIR="$DEVICE_DIR/cellnet-test-$TIMESTAMP-$$"
mkdir -p "$RESULT_DIR" || {
    echo "ERROR: unable to create result directory: $RESULT_DIR" >&2
    exit 2
}
SUMMARY_FILE="$RESULT_DIR/summary.txt"
: > "$SUMMARY_FILE"

say_result() {
    STATUS="$1"
    TEST_NAME="$2"
    DETAIL="$3"
    printf '%-5s %-28s %s\n' "$STATUS" "$TEST_NAME" "$DETAIL" | tee -a "$SUMMARY_FILE"
}

pass_test() {
    PASS_COUNT=$((PASS_COUNT + 1))
    say_result "PASS" "$1" "$2"
}

fail_test() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    say_result "FAIL" "$1" "$2"
}

skip_test() {
    SKIP_COUNT=$((SKIP_COUNT + 1))
    say_result "SKIP" "$1" "$2"
}

safe_name() {
    echo "$1" | tr ' /' '__' | tr -cd 'A-Za-z0-9_.-'
}

assert_output() {
    OUTPUT_FILE="$1"
    shift
    for EXPECTED_PATTERN in "$@"; do
        if ! grep -Eq "$EXPECTED_PATTERN" "$OUTPUT_FILE"; then
            echo "missing output pattern: $EXPECTED_PATTERN"
            return 1
        fi
    done
    return 0
}

assert_english() {
    OUTPUT_FILE="$1"
    if grep -Eiq 'Continuando|RAT principal|SERVICOS|BANDAS|Pode levar|Opcao desconhecida|ultimo evento|Ambiente validado' "$OUTPUT_FILE"; then
        echo "Portuguese text detected"
        return 1
    fi
    return 0
}

run_cellnet() {
    TEST_NAME="$1"
    shift
    EXPECTED="$1"
    shift
    LOG_FILE="$RESULT_DIR/$(safe_name "$TEST_NAME").log"

    "$CELLNET_PATH" "$@" > "$LOG_FILE" 2>&1
    RC=$?
    if [ "$RC" -ne 0 ]; then
        fail_test "$TEST_NAME" "exit=$RC log=$LOG_FILE"
        return 1
    fi
    if ! assert_output "$LOG_FILE" "$EXPECTED"; then
        fail_test "$TEST_NAME" "unexpected output log=$LOG_FILE"
        return 1
    fi
    if ! assert_english "$LOG_FILE"; then
        fail_test "$TEST_NAME" "non-English output log=$LOG_FILE"
        return 1
    fi
    pass_test "$TEST_NAME" "exit=0 log=$LOG_FILE"
    return 0
}

run_expected_failure() {
    TEST_NAME="$1"
    shift
    EXPECTED="$1"
    shift
    LOG_FILE="$RESULT_DIR/$(safe_name "$TEST_NAME").log"

    "$CELLNET_PATH" "$@" > "$LOG_FILE" 2>&1
    RC=$?
    if [ "$RC" -eq 0 ]; then
        fail_test "$TEST_NAME" "unexpected exit=0 log=$LOG_FILE"
        return 1
    fi
    if ! assert_output "$LOG_FILE" "$EXPECTED"; then
        fail_test "$TEST_NAME" "wrong error output, exit=$RC log=$LOG_FILE"
        return 1
    fi
    if ! assert_english "$LOG_FILE"; then
        fail_test "$TEST_NAME" "non-English output log=$LOG_FILE"
        return 1
    fi
    pass_test "$TEST_NAME" "expected failure exit=$RC log=$LOG_FILE"
    return 0
}

run_optional_tower_lookup() {
    LOG_FILE="$RESULT_DIR/tower-lookup.log"
    "$CELLNET_PATH" tower-lookup > "$LOG_FILE" 2>&1
    RC=$?
    if [ "$RC" -eq 0 ]; then
        if assert_output "$LOG_FILE" '^OPENCELLID TOWER LOOKUP$'; then
            pass_test "tower-lookup" "exit=0 log=$LOG_FILE"
        else
            fail_test "tower-lookup" "unexpected output log=$LOG_FILE"
        fi
    elif [ "$RC" -eq 3 ] &&
         grep -q '^ERROR: OpenCellID returned no usable coordinates:' "$LOG_FILE"; then
        skip_test "tower-lookup" "cell unavailable from provider; log=$LOG_FILE"
    else
        fail_test "tower-lookup" "exit=$RC log=$LOG_FILE"
    fi
}

check_source_pattern() {
    TEST_NAME="$1"
    EXPECTED="$2"
    if grep -Eq -- "$EXPECTED" "$CELLNET_PATH"; then
        pass_test "$TEST_NAME" "source invariant present"
    else
        fail_test "$TEST_NAME" "source invariant missing"
    fi
}

cleanup() {
    trap - 0 1 2 15
    if [ "$RESTORE_REQUIRED" -eq 1 ]; then
        echo "Restoring automatic carrier selection..."
        "$CELLNET_PATH" auto > "$RESULT_DIR/cleanup-auto.log" 2>&1
        CLEANUP_RC=$?
        if [ "$CLEANUP_RC" -eq 0 ]; then
            pass_test "cleanup-auto" "automatic selection restored"
        else
            fail_test "cleanup-auto" "exit=$CLEANUP_RC log=$RESULT_DIR/cleanup-auto.log"
        fi
        RESTORE_REQUIRED=0
    fi
}

trap cleanup 0
trap 'echo; echo "Test interrupted; running cleanup."; cleanup; exit 130' 1 2 15

echo "cellnet on-device test"
echo "Binary:  $CELLNET_PATH"
echo "PATH:    $PATH"
echo "Results: $RESULT_DIR"
echo

if [ ! -f "$CELLNET_PATH" ]; then
    fail_test "binary-present" "not found: $CELLNET_PATH"
    cleanup
    exit 2
fi
if [ ! -x "$CELLNET_PATH" ]; then
    fail_test "binary-executable" "run: chmod +x $CELLNET_PATH"
    cleanup
    exit 2
fi
pass_test "binary-present" "$CELLNET_PATH"

RESOLVED_CELLNET="$(command -v cellnet 2>/dev/null || true)"
if [ "$RESOLVED_CELLNET" = "$CELLNET_PATH" ]; then
    pass_test "path-resolution" "$RESOLVED_CELLNET"
else
    fail_test "path-resolution" "expected $CELLNET_PATH, got ${RESOLVED_CELLNET:-not-found}"
fi

if sh -n "$CELLNET_PATH" > "$RESULT_DIR/sh-n.log" 2>&1; then
    pass_test "POSIX-syntax" "sh -n"
else
    fail_test "POSIX-syntax" "log=$RESULT_DIR/sh-n.log"
fi

check_source_pattern "TIM-PLMN-source" '^TIM_PLMN="72403"$'
check_source_pattern "Vivo-PLMN-source" '^VIVO_PLMN="72410"$'
check_source_pattern "automatic-server" '^SPEEDTEST_MODE_DEFAULT="auto"$'
check_source_pattern "wwan0-binding" '--intf "[$]WWAN_IF"'
check_source_pattern "bidirectional-test" '-d both'
if grep -Eq -- '--nas-set-system-selection-preference=.*(5gnr|lte)' "$CELLNET_PATH"; then
    fail_test "no-RAT-selection" "prohibited RAT selection found in source"
else
    pass_test "no-RAT-selection" "no prohibited RAT selection"
fi

if command -v qmicli >/dev/null 2>&1; then
    qmicli --version > "$RESULT_DIR/qmicli-version.log" 2>&1
    pass_test "qmicli-present" "$(command -v qmicli)"
else
    fail_test "qmicli-present" "not found in PATH"
fi

if [ -e /dev/wwan0qmi0 ]; then
    pass_test "QMI-device" "/dev/wwan0qmi0"
else
    fail_test "QMI-device" "/dev/wwan0qmi0 not found"
fi

if [ -e /sys/class/net/wwan0 ]; then
    pass_test "WWAN-interface" "wwan0"
else
    fail_test "WWAN-interface" "wwan0 not found"
fi

run_cellnet "help" '^Version: [0-9]+[.][0-9]+[.][0-9]+-[A-Za-z0-9._-]+$' help || true
run_cellnet "status" '^Current network$' status || true
run_cellnet "preferences" '^MODEM PREFERENCES$' preferences || true
run_cellnet "signal" '^RADIO SIGNAL$' signal || true
run_cellnet "cell" '^CELL / FREQUENCIES$' cell || true
run_cellnet "radio" '^LTE / 5G SERVICES$' radio || true
run_cellnet "rf" '^RF / BANDS / CARRIER AGGREGATION$' rf || true
run_cellnet "full" '^Current network$' full || true
run_cellnet "cells" '^SERVING CELL INTELLIGENCE$' cells || true
run_cellnet "tower-id" '^TOWER LOOKUP IDENTIFIERS$' tower-id || true
run_cellnet "neighbors" '^NEIGHBORING CELL INFORMATION$' neighbors || true
run_cellnet "neighbors-table" '^NEIGHBORING CELL SUMMARY$' neighbors table || true
run_cellnet "neighbors-csv" '^type,rat,plmn,tac,eci,pci,earfcn,band,' neighbors-csv || true
run_cellnet "neighbors-json" '^\[$' neighbors-json || true
if ! grep -Eq '^[[:space:]]*Intrafrequency LTE Info$' "$RESULT_DIR/neighbors.log"; then
    skip_test "neighbors-csv-records" "QMI returned no intrafrequency LTE section"
    skip_test "neighbors-json-records" "QMI returned no intrafrequency LTE section"
else
    if grep -Eq '^(serving|neighbor),LTE,' "$RESULT_DIR/neighbors-csv.log"; then
        pass_test "neighbors-csv-records" "structured LTE records present"
    else
        fail_test "neighbors-csv-records" "no structured LTE records; inspect $RESULT_DIR/neighbors-csv.log"
    fi
    if grep -Eq '^[[:space:]]*\{"type":"(serving|neighbor)"' "$RESULT_DIR/neighbors-json.log"; then
        pass_test "neighbors-json-records" "structured LTE records present"
    else
        fail_test "neighbors-json-records" "no structured LTE records; inspect $RESULT_DIR/neighbors-json.log"
    fi
fi
run_cellnet "tower-export-json" '^[{]$' tower-export json || true
run_cellnet "tower-export-csv" '^plmn,carrier,mcc,mnc,rat,tac,eci,' tower-export csv || true
run_cellnet "observe-cells" '^timestamp,plmn,rat,tac,eci,' observe-cells "$OBSERVE_SECONDS" || true
run_cellnet "survey-report" '^CELL SURVEY SUMMARY$' survey-report "$RESULT_DIR/observe-cells.log" || true
if [ -n "${OPENCELLID_API_KEY:-}" ] &&
   [ -n "${CELLNET_LATITUDE:-}" ] && [ -n "${CELLNET_LONGITUDE:-}" ]; then
    run_optional_tower_lookup
else
    skip_test "tower-lookup" "set OpenCellID key and device coordinates to enable"
fi
if grep -Eq 'Primary RAT:[[:space:]]+(umts|gsm|wcdma)' "$RESULT_DIR/status.log"; then
    if grep -Eq 'LTE ECI / Cell ID:[[:space:]]+n/a$' "$RESULT_DIR/cells.log" &&
       grep -Eq 'LTE band:[[:space:]]+n/a$' "$RESULT_DIR/cells.log" &&
       grep -Eq 'eNodeB ID:[*]?[[:space:]]+n/a$' "$RESULT_DIR/tower-id.log"; then
        pass_test "non-LTE-labeling" "LTE identifiers remain n/a on non-LTE RAT"
    else
        fail_test "non-LTE-labeling" "fabricated LTE fields detected; inspect cells/tower-id logs"
    fi
else
    skip_test "non-LTE-labeling" "serving RAT is LTE or unavailable"
fi
run_cellnet "snapshot" '^SNAPSHOT: self-test$' snapshot self-test || true
run_cellnet "watch" '^Read-only radio monitor:' watch "$WATCH_SECONDS" || true
run_cellnet "stability" '^RF STABILITY SUMMARY$' stability "$STABILITY_SECONDS" || true

run_expected_failure "invalid-watch" '^ERROR: Duration must be greater than zero[.]$' watch 0 || true
run_expected_failure "invalid-stability" '^ERROR: Invalid duration:' stability invalid || true
run_expected_failure "invalid-neighbors-format" '^ERROR: Unsupported neighbors format:' neighbors invalid || true
run_expected_failure "unknown-command" '^Unknown option: self-test-invalid$' self-test-invalid || true

if [ "$RUN_SCAN" -eq 1 ]; then
    run_cellnet "scan" '^CARRIER SCAN$' scan || true
else
    skip_test "scan" "enable with --scan"
fi

if [ "$RUN_CARRIER" -eq 1 ]; then
    RESTORE_REQUIRED=1
    run_cellnet "carrier-auto" '^Selecting carrier automatically$' auto || true
    run_cellnet "carrier-TIM" '^Selecting TIM$' tim || true
    run_cellnet "TIM-status" 'PLMN:[[:space:]]+72403$' status || true
    run_cellnet "carrier-Vivo" '^Selecting VIVO$' vivo || true
    run_cellnet "Vivo-status" 'PLMN:[[:space:]]+72410$' status || true
    run_cellnet "RF-comparison" '^ TIM x VIVO RF COMPARISON$' compare || true
else
    skip_test "carrier-switching" "enable with --carrier"
    skip_test "RF-comparison" "enable with --carrier"
fi

if [ "$RUN_SPEED" -eq 1 ]; then
    if command -v ui-speed >/dev/null 2>&1; then
        run_cellnet "speedtest-auto" '^SPEEDTEST MOBILE$' speedtest "$SPEED_SECONDS" || true
        run_cellnet "speedtest-fixed" '^SPEEDTEST MOBILE$' speedtest-fixed "$SPEED_SECONDS" || true
        if [ "$RUN_CARRIER" -eq 1 ]; then
            run_cellnet "compare-speed" '^ TIM x VIVO SUMMARY$' compare-speed "$SPEED_SECONDS" || true
            run_cellnet "compare-speed-fixed" '^ TIM x VIVO SUMMARY$' compare-speed-fixed "$SPEED_SECONDS" || true
        else
            skip_test "compare-speed" "requires --carrier with --speed"
            skip_test "compare-speed-fixed" "requires --carrier with --speed"
        fi
    else
        fail_test "ui-speed-present" "required by --speed but not found"
    fi
else
    skip_test "speed-tests" "enable with --speed; consumes cellular data"
fi

cleanup

if [ "$RUN_CARRIER" -eq 1 ]; then
    run_cellnet "post-cleanup-status" '^Current network$' status || true
    run_cellnet "post-cleanup-preferences" '^MODEM PREFERENCES$' preferences || true
fi

echo
echo "============================================================"
echo "SELF-TEST SUMMARY"
echo "============================================================"
echo "PASS: $PASS_COUNT"
echo "FAIL: $FAIL_COUNT"
echo "SKIP: $SKIP_COUNT"
echo "Logs: $RESULT_DIR"

if [ "$FAIL_COUNT" -ne 0 ]; then
    echo "RESULT: FAIL"
    exit 1
fi

echo "RESULT: PASS"
exit 0
