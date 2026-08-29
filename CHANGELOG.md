# Changelog

## Documentation update
- Added project motivation and multi-network eSIM use case.
- Documented the Hypecon MVNO test environment with TIM/Vivo host networks.
- Added regional/conditional Claro availability note.
- Added practical explanation of why automatic network selection may not provide the best performance.
- Added dedicated `USE-CASE-AND-TEST-ENVIRONMENT.md` documentation.

## v9.3-stable-sampling-3s
- Reduced RF/CA sampling interval from 5 s to 3 s.
- Preserved v9.2 result-record fixes.

## v9.2-stable-record-fix
- Corrected speed-test result field count.
- Corrected retry error-field parsing.
- Corrected selected-server field parsing.
- Prevented blank selected-server display.

## v9.1-stable-warmup-debug
- Added short speed-test warm-up.
- Added first-failure diagnostics.
- Added best-effort selected-server extraction.

## v9.0-stable-auto-server
- Automatic server selection became the default.
- Added `speedtest-fixed`.
- Added `compare-speed-fixed`.

## v8.x
- Removed redundant NSA stabilization wait when NSA is already active.
- Added phase-aware RF/CA monitoring for download and upload.

## v7.x
- Consolidated stable command baseline.
- Restored `speedtest_current()` after a regression.

## Earlier development
- Added carrier selection, diagnostics, snapshots, RF comparison, forced `wwan0` throughput testing and LTE-CA monitoring.
