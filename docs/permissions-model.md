# Permissions Model

This repository relies on path-based permissions plus agent instructions.

## Intended boundaries

- `manager` is read-only across the repository.
- `spec-builder` can read repository context and write only to `specs/`.
- `spec-implementor` can read specs and write implementation code, but cannot access `scenarios/`.
- `scenario-validator` can read and write `scenarios/` and run the system, but cannot read implementation code.

## Strongly enforceable

- Directory-level read and write restrictions.
- Tool denials for editing-capable agents.

## Only partially enforceable

- Preventing inference through runtime logs, process names, or packaged outputs.
- Preventing disclosure if forbidden information is passed directly in prompts.
- Preventing shell access if an installation ignores path-based restrictions for `bash`.

## Closest practical alternative

If stronger isolation is required, build a packaged runtime artifact and let `scenario-validator` operate on that package instead of the source tree.
