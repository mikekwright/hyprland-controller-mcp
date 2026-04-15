# Dark Factory Workflow

The workflow is designed to separate planning, implementation, and validation.

## Sequence

1. `manager` receives a task.
2. `spec-builder` writes the spec package under `specs/`.
3. A spec is approved in `approval.md`.
4. `spec-implementor` changes code in `src/`, `tests/`, and related implementation areas.
5. `scenario-validator` runs validation flows from `scenarios/` and stores artifacts.

## Intent

- Validators should not depend on implementation knowledge.
- Implementors should not tailor code to private scenarios.
- Specs are the handoff artifact between request and implementation.

## Enforcement

OpenCode path permissions are used where possible.
Anything not strictly enforceable through tool permissions remains a repository policy and must be treated as mandatory.
