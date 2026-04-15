# Capture Screenshots

## Problem

The MCP server needs a Wayland-native screenshot capability so an agent can inspect the current Hyprland desktop state without relying on scenario-validator artifacts. The feature should use maintainable adapters around `grim` and related Wayland tooling rather than ad hoc shell logic.

## Goals

- Add MCP screenshot functionality backed by `grim`.
- Support entire screen capture for a specified monitor.
  - If no monitor is specified, it should default to the main monitor when Hyprland monitor inspection is available.
  - If Hyprland monitor inspection is unavailable, it should capture all monitors as one combined image and treat that result as a single synthetic monitor.
- Support explicit region capture for a caller-supplied area.
- Expose current display geometry metadata so an agent can reason about monitor size before choosing a capture region.
  - This should provide a structured entry for each monitor, including monitor number and screen geometry.
  - If Hyprland monitor inspection is unavailable but a reliable combined-desktop geometry can still be derived, display inspection may return one synthetic combined-desktop entry instead of per-monitor entries.
- Return screenshot data in a form that is useful to MCP clients without creating long-lived files in the repository.
- Prefer PNG output for lossless readability.
- The tool should respond using an MCP-native binary response shape rather than a repository file path.
- If the MCP server is run on a non-Linux system, it should still provide the tool, but the tool response must indicate
  that the current system is unsupported.

## Non-goals

- Adding screen recording.
- Moving the pointer, changing focus, or selecting an area interactively.
- Supporting X11-specific capture flows.
- Persisting screenshots under `scenarios/` or other long-lived artifact locations as part of normal tool execution.

## Constraints

- Runtime integration must preserve repository boundaries in `AGENTS.md`; screenshot support belongs in `src/`, not `scenarios/`.
- The implementation should follow the documented architecture split between MCP tool handlers and Wayland adapters.
- `grim` should be packaged for Linux targets. Darwin packages may omit `grim`; in that environment the screenshot capability must fail clearly or remain unavailable rather than pretending capture is supported.
- Region capture should use explicit geometry input and Wayland-native tooling. Interactive `slurp` usage is optional for this feature and should not be required for baseline support.
  - If monitor inspection is unavailable, a caller-supplied region must be interpreted in compositor/global desktop coordinates exactly as passed to `grim`, not rebased to a monitor-local or synthetic image-local origin.
  - In that fallback mode, `x` and `y` may be negative if the compositor desktop layout uses negative coordinates. The implementation must still validate that `width` and `height` are positive, but it does not need to precompute combined-desktop bounds before invoking `grim`.
- Temporary files are acceptable only as an internal transport detail and must be cleaned up after use.
- To determine the main monitor, use Hyprland monitor inspection data.
  - If Hyprland monitor inspection is unavailable, the screenshot tool should return a screenshot of all monitors combined and treat it as a single monitor.
  - If a caller explicitly supplies `monitor` but Hyprland monitor inspection is unavailable, the tool must return a clear structured error instead of silently ignoring `monitor` or guessing.
  - If Hyprland monitor inspection does not identify which monitor is primary, choose the default monitor deterministically by lowest numeric identifier when identifiers are numeric, otherwise by lowest identifier/name in alphabetical order.

## Functional requirements

- Provide one MCP tool for image capture and one MCP tool for display inspection, or an equivalent interface with the same capabilities.
- Screenshot capture must support at least:
  - full-output capture of the specified monitor, or the default monitor when no monitor is supplied
  - region capture when the caller supplies `x`, `y`, `width`, and `height`, with monitor-scoped behavior when monitor geometry is available and combined-global behavior when monitor inspection is unavailable
- The screenshot response must include enough metadata for a client to identify what was captured and how to interpret coordinates.
  - At minimum, metadata must include:
    - `format`
    - `targetKind`, with values `monitor` or `combined-desktop`
    - `coordinateMode`, with values `monitor-local` or `desktop-global`
    - `bounds` as `{ x, y, width, height }`, always interpreted in the declared `coordinateMode`
    - `imageSize` as `{ width, height }`, always describing the returned PNG pixel dimensions
  - When `targetKind` is `monitor`, metadata must also include the resolved monitor identifier and/or monitor number.
  - When monitor geometry is known, metadata should also include `targetBounds` in desktop-global coordinates for the selected monitor.
  - When monitor inspection is unavailable and a combined-desktop fallback is used, `targetBounds` may be omitted if the compositor-global combined bounds cannot be determined reliably.
- Display inspection must return monitor numbering and dimensions in a structured format suitable for later region selection.
  - If per-monitor inspection is unavailable, display inspection must either return one synthetic combined-desktop entry with explicit fallback metadata or fail with a clear unavailable-state response.
- Invalid region input such as non-positive width or height must return a clear error.
- Dependency or environment failures such as missing `grim`, unavailable Wayland session variables, or unsupported platform must return a clear error.

## Interface notes

- The preferred screenshot contract is a PNG image plus structured metadata.
- The preferred display-inspection contract is structured JSON describing one or more active outputs, including width and height.
- If the implementation needs to encode image bytes for transport, base64 is acceptable.
- If multiple monitors are present, whole-output capture and output metadata should make it clear which output was captured or reported.
- In fallback mode without monitor inspection, clients must rely on `coordinateMode` rather than assume that capture bounds are monitor-local.

## Acceptance criteria

- The MCP server exposes screenshot-related functionality for capture and display inspection.
- On supported Linux/Wayland environments with `grim` available, whole-output capture succeeds and returns PNG image content with metadata.
- On supported Linux/Wayland environments with valid region arguments, region capture succeeds and returns PNG image content with metadata reflecting the requested area.
- Display inspection returns structured geometry that includes width and height for active outputs, or one explicit synthetic combined-desktop entry when per-monitor inspection is unavailable.
- Invalid region arguments fail with a clear, structured error.
- Unsupported environments such as Darwin without `grim`, or Linux sessions without required Wayland context, fail clearly instead of producing misleading success.
- Normal screenshot execution does not leave long-lived files in the repository.
