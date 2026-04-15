# Hyprland MCP Bootstrap Plan

## Scope

Create the initial repository structure, policy files, templates, and placeholders required to begin dark-factory development.

## Implementation approach

- Add root configuration files
- Add agent workflow documentation
- Add template content under `specs/` and `scenarios/`
- Add empty implementation package placeholders under `src/`
- Add validator-safe script placeholders under `scripts/`
- Add Nix packaging and host integration modules under `flake.nix` and `nix/`

## Files or modules expected to change

- `opencode.json`
- `AGENTS.md`
- `README.md`
- `docs/**`
- `specs/**`
- `scenarios/**`
- `src/**`
- `tests/**`
- `scripts/**`
- `flake.nix`
- `nix/**`

## Risks

- OpenCode permission enforcement may vary by installation
- Validator isolation remains partly policy-based while source and runtime share one repository

## Validation plan

- Confirm the expected tree exists
- Confirm restricted directories are documented per agent
- Confirm artifact folders are ignored and present
- Confirm the flake evaluates and exposes the expected output categories
