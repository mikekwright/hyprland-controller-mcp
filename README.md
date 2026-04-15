# Hyprland MCP Dark Factory

This repository bootstraps a dark-factory workflow for an MCP server that can control and validate a Linux desktop running Hyprland.

The repository is intentionally split into separate areas for planning, implementation, and validation:

- `specs/` stores structured feature specs and implementation plans.
- `src/` stores MCP server and adapter implementation.
- `scenarios/` stores validation scenarios, run records, and artifacts.

The workflow is enforced through four agents defined in `opencode.json` and documented in `AGENTS.md`:

1. `manager`
2. `spec-builder`
3. `spec-implementor`
4. `scenario-validator`

This initial bootstrap does not implement application behavior yet. It establishes repository structure, operating rules, and placeholders for the first implementation cycle.

## Nix bootstrap

The repository includes a `flake.nix` that exposes:

- `packages.<system>.default` for installing the bootstrap package
- `apps.<system>.default` for running the packaged entrypoint
- `devShells.<system>.default` for a minimal development shell
- `nixosModules.default` for NixOS installation
- `darwinModules.default` for nix-darwin installation

Current limitation: the package installs bootstrap entrypoints only. It does not yet provide a working MCP server runtime.
