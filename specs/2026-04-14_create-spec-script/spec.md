# Create Spec Script

## Problem

Creating a new feature handoff currently requires manual setup across `specs/` and `scenarios/definitions/`. That makes the dark-factory
workflow slower and increases the chance of inconsistent folder names or missing template files.

## Goals

- Add a `scripts/create-spec.sh` helper that accepts a feature name.
- Derive a stable feature slug from the provided name.
- The folder name will start with the current date in format YYYY-MM-DD, using the timezone of the computer that the script is run from.
- Generate `specs/<date>_<feature-slug>/` from `specs/_templates`.
  - If the folder already exists, the script should fail with an error that the folder already exists and the scenario folder should also not be created.
- Generate `scenarios/definitions/<date>_<feature-slug>/` from `scenarios/_templates`.
  - If the folder already exists, the script should fail with an error that the folder already exists and the spec folder should also not be created.
- Add a root `Makefile` target named `new-scenario` that runs the script.

## Non-goals

- Changing the contents of the existing spec templates.
- Changing the contents of the existing scenario templates.
- Running validation or generating any scenario artifacts.
- Adding approval automation or auto-marking new specs as approved.

## Constraints

- The script must live under `scripts/create-spec.sh`.
- The script must work from the repository root through a root `Makefile` target.
- Generated spec packages must preserve the required dark-factory files: `spec.md`, `plan.md`, and `approval.md`.
- New spec approvals must remain pending until a separate approval step updates them.
- Implementation should avoid modifying tracked files under `scenarios/` beyond runtime-generated scaffold output.

## Acceptance criteria

- Running the new script with a feature name creates `specs/<date>_<feature-slug>/` populated from `specs/_templates`.
- Running the new script with the same feature name also creates `scenarios/definitions/<date>_<feature-slug>/` populated from `scenarios/_templates`.
- The feature slug is normalized consistently enough to support names with spaces and mixed casing.
- The script fails with a clear error when no feature name is provided.
- The script fails safely when the destination spec or scenario definition directory already exists, without overwriting existing files silently.
- A root `Makefile` exists and exposes a `new-scenario` target that invokes `scripts/create-spec.sh`.
- Newly created `specs/<date>_<feature-slug>/approval.md` remains in a pending state unless a later approval action changes it.
