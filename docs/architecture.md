# Architecture

This project is an MCP server for validating a Hyprland desktop on Linux.

The repository is organized into three distinct work areas:

- `specs/` for planning and approval artifacts
- `src/` for implementation
- `scenarios/` for runtime validation definitions and artifacts

Implementation architecture should preserve these separations:

- MCP transport concerns live under `src/mcp_server/transport/`.
- MCP tool handlers live under `src/mcp_server/tools/`.
- Hyprland and Wayland integrations live under `src/adapters/`.
- Domain models stay under `src/domain/`.
- Configuration stays under `src/config/`.

Recommended external tools by concern:

- Inspection: `hyprctl`
- Screenshots: `grim`
- Region capture: `slurp`
- Recording: `wf-recorder`
- Keyboard input: `ydotool`, `wtype`
- Parsing support: `jq`

Application code is intentionally not implemented in this bootstrap.

Packaging and installation concerns are bootstrapped through `flake.nix` and `nix/` so the repository can be installed by NixOS and nix-darwin even before the runtime server is implemented.
