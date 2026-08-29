# Development and Regression Policy

The project uses a **stable-baseline, incremental-change** model.

## Baseline rule
Never reconstruct the script from fragments for a feature change. Start from the latest validated baseline.

## Commands that must remain available

```text
tim
vivo
auto
status
full
signal
cell
radio
rf
preferences
scan
snapshot
compare
speedtest
speedtest-fixed
compare-speed
compare-speed-fixed
```

## Mandatory checks

```sh
sh -n cellnet
```

Also verify:
- `ui-speed` remains bound to `wwan0`;
- throughput still uses `-d both`;
- automatic server selection remains default;
- fixed-server commands remain available;
- normal carrier selection does not gain RAT filters;
- `speedtest_current()` and `compare_speed()` exist;
- internal result-record field count/indexes are consistent.

## Dangerous regression

Do not add these to normal carrier-switching paths:

```text
5gnr,manual=<PLMN>
lte,manual=<PLMN>
```

## Internal record schema
The speed-test record is positional. When adding fields:

1. document the schema change;
2. count `printf` placeholders;
3. update `print_speed_record`;
4. update `field_from_record` consumers;
5. test success, retry and error paths.

## Suggested checks

```sh
sh -n cellnet
grep -n '^speedtest_current()' cellnet
grep -n '^compare_speed()' cellnet
grep -n -- '--intf "$WWAN_IF"' cellnet
grep -n -- '-d both' cellnet
```

The included GitHub Actions workflow runs syntax validation and ShellCheck.
