# Tooling Baseline

The MCP server is expected to integrate with Hyprland and Wayland-native utilities through adapter modules.

## Recommended baseline

- `hyprctl` for window, workspace, and session inspection
- `grim` for full-screen or targeted screenshots
- `slurp` for selecting regions
- `wf-recorder` for screen or region video recording
- `ydotool` for low-level input events
- `wtype` for text typing flows where it is sufficient
- `jq` for structured parsing of CLI JSON output

## Rationale

These tools fit Hyprland and Wayland better than X11-first alternatives and keep the implementation focused on stable adapters instead of ad hoc shell flows.
