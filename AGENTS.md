# AGENTS

This repository uses a dark-factory workflow with strict separation between planning, implementation, and validation.

## Core Rule

There are exactly four agents:

1. `manager`
2. `spec-builder`
3. `spec-implementor`
4. `scenario-validator`

No other agent roles should be introduced without explicitly changing this file and `opencode.json`.

## Workflow

All work must follow this sequence:

1. `manager` receives the request.
2. `manager` delegates planning to `spec-builder`.
3. `spec-builder` creates or updates a spec package under `specs/<feature-slug>/`.
4. A human or workflow approval step marks the spec as approved.
5. `manager` delegates implementation to `spec-implementor`.
6. `spec-implementor` implements the approved plan in project code.
7. `manager` delegates validation to `scenario-validator`.
8. `scenario-validator` runs scenarios and stores artifacts under `scenarios/`.

## Agent Rules

### manager

- Default and primary agent.
- May read the repository.
- Must not edit any files.
- Must not implement code.
- Must not create or modify scenarios.
- Must only coordinate, review status, and route work.

### spec-builder

- May read project code and documentation.
- May read and write only `specs/`.
- Must not access `scenarios/`.
- Must not modify implementation code.
- Output must be structured and stored under `specs/<feature-slug>/`.

Required spec files:

- `spec.md`
- `plan.md`
- `approval.md`

### spec-implementor

- May read approved specs.
- May read and write implementation code and tests.
- Must not access `scenarios/`.
- Must not define or update validation scenarios.
- Must implement only what is covered by an approved spec plan.

### scenario-validator

- May read and write only validator-operational areas and `scenarios/`.
- Must not read `src/`, `tests/`, or `specs/`.
- Must not modify implementation code.
- May run the application and validation workflows.
- Must store screenshots, videos, logs, and manifests under `scenarios/artifacts/` and `scenarios/runs/`.

## Repository Boundaries

### `specs/`

Planning area only.
Contains structured feature specs, implementation plans, and approval state.

### `src/`

Implementation area only.
Contains MCP server code, adapters, domain logic, and configuration.

### `scenarios/`

Validation area only.
Contains scenario definitions, fixtures, run records, artifact manifests, screenshots, recordings, and logs.

Artifacts are not source code.

## Tooling Principles

- Prefer maintainable adapter modules over shell-script sprawl.
- Keep MCP transport code separate from Hyprland and Wayland adapters.
- Prefer Hyprland and Wayland-native tools where practical.
- Recommended tools include:
  - `hyprctl` for compositor, session, and window inspection
  - `grim` for screenshots
  - `slurp` for region selection
  - `wf-recorder` for video capture
  - `ydotool` and `wtype` for input synthesis
  - `jq` for stable CLI JSON parsing when needed

## Safety Rules

- `scenario-validator` must be treated as implementation-blind.
- `spec-builder` and `spec-implementor` must be treated as scenario-blind.
- If a requested task would cross these boundaries, stop and escalate through `manager`.
- Do not store runtime artifacts in `src/`, `tests/`, or `specs/`.
- Do not store source code in `scenarios/artifacts/`.

## Approval Model

Implementation starts only after `specs/<feature-slug>/approval.md` marks the spec approved.

Validation starts only after implementation is complete enough to run.

## Definition of Done

A feature is only complete when:

1. A spec package exists under `specs/`.
2. Implementation exists in `src/` and relevant supporting areas.
3. A validation scenario exists under `scenarios/definitions/`.
4. Validation artifacts and a report exist under `scenarios/`.
