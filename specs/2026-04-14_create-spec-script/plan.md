# Create Spec Script Plan

## Scope

Add repository-level scaffolding automation for new workflow entries so a single command can create both a spec package and a scenario definition package from existing templates, with both generated directory names prefixed by the current date in `YYYY-MM-DD` format using the local timezone of the computer running the script.

## Implementation approach

- Add a new shell script at `scripts/create-spec.sh`.
- Accept the feature name from command-line arguments so multi-word names are supported.
- Normalize the feature name into a filesystem-safe slug, expected to be lowercase and hyphen-delimited.
- Derive the current date inside the script at runtime in `YYYY-MM-DD` format using the local timezone of the computer where the script is executed, and use it as a required prefix for both generated directory names.
- Build a single scaffold identifier as `<date>_<feature-slug>` and use the same identifier for `specs/<date>_<feature-slug>/` and `scenarios/definitions/<date>_<feature-slug>/`.
- Resolve repository-relative template and destination paths inside the script.
- Verify that both source template directories exist before attempting generation.
- Refuse to continue if the feature name is empty after normalization.
- Refuse to continue if the derived date string is empty or does not match the expected `YYYY-MM-DD` shape before using it in paths.
- Generate `specs/<date>_<feature-slug>/` from `specs/_templates`.
- Generate `scenarios/definitions/<date>_<feature-slug>/` from `scenarios/_templates`.
- Perform preflight collision checks on both destination paths before creating either directory.
- If `specs/<date>_<feature-slug>/` already exists, exit with a clear error and do not create `scenarios/definitions/<date>_<feature-slug>/`.
- If `scenarios/definitions/<date>_<feature-slug>/` already exists, exit with a clear error and do not create `specs/<date>_<feature-slug>/`.
- Treat an existing same-day scaffold for the same slug as a collision and fail clearly rather than trying to append counters or create alternate names.
- Create both destination directories only after all preflight checks pass so the script never creates one destination when the other destination already exists.
- Copy all files from `specs/_templates/` into `specs/<date>_<feature-slug>/`.
- Copy all files from `scenarios/_templates/` into `scenarios/definitions/<date>_<feature-slug>/`.
- Preserve template-provided file contents, including pending approval state in `approval.md`.
- Add a root `Makefile` with a `new-scenario` target that forwards the requested feature name to `scripts/create-spec.sh`.
- Standardize the supported `Makefile` invocation shape so the feature name is passed via a variable such as `NAME`, avoiding ambiguous positional argument handling in `make`.
- Ensure the script is invoked from repository root context when called through `make new-scenario NAME="..."`.

## Files or modules expected to change

- `scripts/create-spec.sh` (new)
- `Makefile` (new, since no root `Makefile` currently exists)

## Edge cases

- No arguments provided.
- Feature names with repeated spaces, leading/trailing whitespace, or mixed case.
- Feature names containing punctuation or path separators that should not become raw directory names.
- Normalization producing an empty slug.
- Current-date generation producing an unexpected value or format; implementation should validate the generated date before using it in destination names.
- Date boundaries, timezone differences, and locale differences; implementation should rely on a stable machine-readable date command format that uses the executing computer's local timezone rather than locale-dependent output.
- Same feature name run multiple times on the same date, which should fail due to directory collision rather than generating a second unique variant.
- Same feature name run on different dates, which should succeed because the date-prefixed scaffold identifier changes.
- `specs/_templates` missing or incomplete.
- `scenarios/_templates` missing or incomplete.
- Destination spec directory already exists; the script must fail before creating the scenario definition directory.
- Destination scenario definition directory already exists; the script must fail before creating the spec directory.
- Partial creation risk if copy work fails after destination creation; implementation should minimize or clean up partial scaffold state where practical, while preserving the required no-create-on-collision behavior.
- Invocation through `make new-scenario NAME="..."` with shell-sensitive characters in the requested name.

## Acceptance criteria

- `scripts/create-spec.sh "Create Spec Script"` creates `specs/<date>_create-spec-script/` and `scenarios/definitions/<date>_create-spec-script/` from their respective templates, where `<date>` is the current date in `YYYY-MM-DD` format in the local timezone of the computer running the script.
- The generated spec package contains at least `spec.md`, `plan.md`, and `approval.md`.
- The generated approval file remains pending because it comes from the template state.
- The generated spec and scenario definition directories use the same `<date>_<feature-slug>` identifier for a single invocation.
- Slug generation handles names with spaces and mixed casing consistently enough to produce a lowercase hyphenated slug.
- The script exits non-zero and prints a usable message when invoked without a feature name.
- The script exits non-zero and prints a usable message when the derived slug is empty or the generated date is not in the expected format.
- The script exits non-zero and prints a usable message when `specs/<date>_<feature-slug>/` already exists, and in that case does not create `scenarios/definitions/<date>_<feature-slug>/`.
- The script exits non-zero and prints a usable message when `scenarios/definitions/<date>_<feature-slug>/` already exists, and in that case does not create `specs/<date>_<feature-slug>/`.
- The script does not silently overwrite existing generated files.
- `make new-scenario NAME="Create Spec Script"` provides a supported path to the same script behavior from the repository root.

## Validation plan

- Review the script logic for argument parsing, slug generation, runtime date generation, path resolution, and overwrite protections.
- Confirm the root `Makefile` exposes `new-scenario` and delegates to `scripts/create-spec.sh` using the documented `NAME` variable contract.
- Dry-run reasoning or unit-style shell verification by the implementor should cover success, missing-name, invalid-slug or invalid-date guardrails, and already-exists cases without requiring scenario validation workflows.
