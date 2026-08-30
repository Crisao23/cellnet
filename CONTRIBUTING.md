# Contributing

Changes should preserve the conservative behavior of the project.

Before submitting:
1. start from the latest stable baseline;
2. preserve existing commands;
3. avoid persistent RAT/band forcing;
4. run `sh scripts/validate.sh`;
5. update `CHANGELOG.md` when behavior changes;
6. include representative output for parser fixes.

See [Development and Regression Policy](docs/DEVELOPMENT.md).

## Incremental workflow

Create a short-lived branch from the current default branch, keep the change focused, and submit it through a pull request. Avoid mixing cleanup or refactoring with behavioral changes.

## Definition of Done

A change is done when:

- its scope and expected behavior are clear;
- compatibility and safety invariants are preserved;
- `sh scripts/validate.sh` passes;
- relevant manual or hardware checks are recorded, including checks not run;
- documentation and `CHANGELOG.md` are updated when behavior changes;
- no unrelated changes or generated artifacts are included;
- the pull request documents validation, risks, and rollback considerations.
