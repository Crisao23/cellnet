# Changelog

## v9.5.0-radio-intelligence
- Added a POSIX on-device self-test harness with output assertions, per-command logs, safe opt-in modes and automatic carrier cleanup.
- Completed the English-language cleanup for remaining source comments, headings and CLI messages.
- Added `cells` for normalized serving-cell, LTE/NR RF and LTE CA diagnostics.
- Added `tower-id` with a compact correlation fingerprint and conservative decimal ECI decomposition.
- Added read-only `watch` monitoring with explicit PLMN/cell/channel change reporting.
- Added `stability` summaries using POSIX `awk`, without speed tests or external packages.
- Kept unavailable or ambiguous modem fields as `n/a`; no NR identifier, tower location or GNSS position is fabricated.
- Preserved PLMN-only carrier selection, all existing commands and speed-test behavior.

## v9.4.2-stable-english-cleanup
- Replaced the remaining Portuguese `RESUMO TIM x VIVO` output with `TIM x VIVO SUMMARY`.
- Preserved all commands, parsing, speed-test behavior and ShellCheck-related fixes from v9.4.1.

## v9.4.1-stable-shellcheck
- Fixed GitHub Actions ShellCheck failures.
- Exposed `CELLNET_BASELINE_VERSION` through CLI help so it is no longer unused.
- Removed unused pre/post RF/CA snapshot variables.
- Removed the unused `UI_RC` parser variable.
- Documented intentional pipe-delimited field splitting with local ShellCheck suppressions for SC2086.
- Preserved runtime behavior and command compatibility.

## v9.4-stable-english
- Converted all script comments, help text, diagnostics and user-facing output to English.
- Converted internal result status tokens to English (`ERROR` / `PARTIAL`).
- Preserved all v9.3 behavior, commands, speed-test modes and 3-second RF/CA sampling.

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
