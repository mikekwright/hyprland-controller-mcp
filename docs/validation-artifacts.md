# Validation Artifacts

Validation outputs are operational evidence, not source code.

## Artifact locations

- Screenshots: `scenarios/artifacts/screenshots/`
- Recordings: `scenarios/artifacts/recordings/`
- Logs: `scenarios/artifacts/logs/`
- Manifests: `scenarios/artifacts/manifests/`
- Run records: `scenarios/runs/`
- Reports: `scenarios/reports/`

## Naming guidance

- Use scenario id plus timestamp.
- Keep one manifest per validation run.
- Store enough metadata to correlate a report with its captured artifacts.

## Validator rule

`scenario-validator` may create and update artifacts, but must not store implementation code in these locations.
