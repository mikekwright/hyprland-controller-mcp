# Permission Matrix

This matrix documents the intended repository and tool access by agent.

| Agent | Read Paths | Write Paths | Allowed Tools | Denied Tools | Notes |
| --- | --- | --- | --- | --- | --- |
| `manager` | entire repository | none | `read`, `glob`, `grep`, `task`, `question` | `bash`, `apply_patch`, write-capable file tools | Default coordinator only |
| `spec-builder` | `README.md`, `AGENTS.md`, `opencode.json`, `docs/`, `src/`, `tests/`, `examples/`, `specs/` | `specs/` | `read`, `glob`, `grep`, `apply_patch`, `task`, `question` | `bash`; all access to `scenarios/` | Planning only |
| `spec-implementor` | `README.md`, `AGENTS.md`, `opencode.json`, `docs/`, `src/`, `tests/`, `scripts/`, `examples/`, `specs/` | `README.md`, `docs/`, `src/`, `tests/`, `scripts/`, `examples/` | `read`, `glob`, `grep`, `apply_patch`, `bash`, `task`, `question` | all access to `scenarios/` | Implementation only |
| `scenario-validator` | `README.md`, `AGENTS.md`, validator docs, validator-safe runner scripts, `scenarios/` | `scenarios/` | `read`, `glob`, `grep`, `apply_patch`, `bash`, `task`, `question` | all access to `src/`, `tests/`, `specs/` | Validation only |

## Enforcement notes

- Path restrictions are the primary technical control.
- Tool restrictions reduce accidental boundary crossing.
- Runtime visibility can still leak implementation details through logs or process output, so validator isolation is not perfect in a single shared repository.
