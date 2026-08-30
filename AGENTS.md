# AGENTS.md

## Scope

These instructions apply to the entire repository.

## Working agreement

- Start from the current baseline and make small, focused changes.
- Preserve existing commands, POSIX `sh` compatibility, and conservative modem behavior.
- Keep `cellnet` and `bin/cellnet` identical when changing the executable.
- Keep source, user-facing text, and repository documentation in English.
- Do not add RAT or band forcing to normal carrier-selection paths.
- Avoid unrelated formatting, generated files, dependencies, and broad refactors.
- Update documentation and `CHANGELOG.md` when behavior changes.

## Validation

Run `sh scripts/validate.sh` before considering a change complete. For modem- or parser-related changes, also follow the regression checks in `docs/DEVELOPMENT.md` and record any hardware validation that could not be performed.

## Delivery

Use a short-lived branch, keep commits reviewable, and open a PR that explains scope, validation, risks, and rollback considerations.
