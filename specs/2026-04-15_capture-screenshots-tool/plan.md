# Capture Screenshots Plan

## Scope

Add implementation-ready planning for Wayland screenshot support in the MCP server using `grim`, including explicit monitor selection, structured monitor numbering and geometry reporting, deterministic default-monitor resolution from Hyprland monitor data, a combined-output fallback when monitor inspection is unavailable, region handling that falls back to combined-monitor global coordinates when monitor inspection does not work, MCP-native binary responses, and a clear supported-platform story where non-Linux runtimes still expose the tool but return unsupported.

## Implementation approach

- Add a Wayland screenshot adapter in `src/adapters/wayland/grim_adapter.py` that is responsible only for invoking `grim`, validating requested monitor/region input, and returning image bytes plus capture metadata.
- Keep CLI execution details behind the existing process-adapter layer rather than embedding subprocess logic directly in MCP tool handlers.
- Add a display-inspection adapter or query helper that uses Hyprland-native monitor inspection data to report active monitor geometry in structured form. The most likely fit is `src/adapters/hyprland/session_query.py` with `hyprctl monitors -j` or equivalent JSON output.
- Implement MCP-facing tool handlers in `src/mcp_server/tools/screenshots.py` for:
  - screenshot capture
  - monitor/display geometry inspection
- Register those tool handlers from the MCP server bootstrap once runtime server wiring exists or as part of the same implementation pass if tool registration is already being added.
- Prefer passing explicit region geometry to `grim` rather than using interactive `slurp` selection. `slurp` may remain unused in the first pass.
- Resolve the requested monitor before capture: when a monitor identifier is supplied, capture that monitor; when omitted, resolve the compositor's main/default monitor from Hyprland monitor data.
- If a monitor identifier is supplied but Hyprland monitor inspection is unavailable, return a structured error rather than silently falling back to combined-output capture.
- Default-monitor resolution must follow this order:
  - use the Hyprland-reported primary/focused/default indicator if one exists in monitor inspection data
  - otherwise choose deterministically by lowest numeric identifier when monitor identifiers are numeric
  - otherwise choose deterministically by lowest identifier/name in alphabetical order
- If Hyprland monitor inspection is unavailable, omit per-monitor default resolution and fall back to a full combined-output screenshot that represents all monitors as one synthetic capture target.
- For region capture, validate against the selected monitor bounds when monitor geometry is available. If monitor inspection does not work, treat the caller-supplied region as compositor/global desktop coordinates exactly as passed to `grim`, report that interpretation in metadata, and limit prevalidation to input shape plus positive width/height.
- Report monitor inspection data as a structured list of active outputs with stable numbering, identifier/name, origin, width, height, and derived bounds so clients can select a monitor or compute valid regions. If Hyprland monitor inspection is unavailable but screenshot capture still works, the implementation may report one synthetic combined output instead of per-monitor geometry.
- Use in-memory bytes where possible. If the chosen `grim` invocation path requires a temporary file, create it outside tracked repository locations and remove it before returning.
- Shape screenshot responses as MCP-native binary content plus structured metadata, instead of returning repository paths or artifact references. Base64 should be treated only as a fallback if the transport layer cannot return binary content directly.
- Package Linux runtime dependencies in Nix so Linux builds include `grim`. On non-Linux platforms, keep the tool registered but route execution through a platform check that returns a structured unsupported response rather than hiding the tool or pretending capture is available.
- Add implementation-facing tests under `tests/unit/` for input validation and adapter/tool response shaping. If lightweight integration tests are practical, keep them mocked or fixture-driven rather than depending on a live compositor.

## Likely tool contracts

- `capture_screenshot`
   - inputs: optional monitor selector and optional region object `{ x, y, width, height }`
   - monitor selector: should accept the stable monitor number and/or the Hyprland monitor identifier/name that display inspection reports
   - behavior: if `monitor` is provided, capture that monitor; if omitted and no region is supplied, capture the default/main monitor resolved from Hyprland monitor data; if Hyprland monitor inspection is unavailable, no-monitor capture falls back to one combined image but monitor-specific capture returns a structured error; if a region is supplied, validate it against the selected monitor's bounds when monitor geometry is available, otherwise interpret the region as compositor/global desktop coordinates
   - outputs: MCP-native PNG image payload plus metadata including `format`, `targetKind`, `coordinateMode`, `bounds`, `imageSize`, resolved monitor identity when applicable, and optional `targetBounds` when monitor geometry is known
- `get_display_info`
   - inputs: none, or optional output filter
   - outputs: structured list of active outputs with monitor number, identifier/name, x, y, width, height, and full geometry/bounds; if Hyprland monitor inspection is unavailable but screenshot fallback remains possible, return one synthetic combined output only when reliable combined-desktop geometry can be determined, otherwise return a clear unavailable-state response; whichever path is used must be consistent with screenshot metadata

Final MCP schema names can vary, but the implemented interface should preserve these capabilities.

## Files or modules expected to change

- `src/adapters/wayland/grim_adapter.py`
- `src/adapters/hyprland/session_query.py`
- `src/adapters/process/command_runner.py`
- `src/mcp_server/tools/screenshots.py`
- `src/mcp_server/server.py`
- `src/domain/tool_results.py`
- `src/mcp_server/transport/models.py`
- `nix/package.nix`
- `flake.nix` and/or `nix/modules/*.nix` if runtime dependency exposure needs adjustment
- `tests/unit/**`
- `tests/integration/**` only if repository test patterns support mocked end-to-end tool registration checks

## Risks

- `grim` behavior depends on a valid Wayland session; failures may be environmental rather than code defects.
- Hyprland monitor JSON may not expose a single canonical "primary" field across environments, so the implementation must document exactly which monitor attributes count as the primary/default signal before falling back to deterministic ordering.
- Multi-monitor handling can be ambiguous if monitor numbering is not derived and documented consistently from Hyprland inspection data.
- The spec now allows a combined-output fallback when monitor inspection is unavailable, which means tool behavior and metadata must clearly distinguish between real per-monitor captures and synthetic combined captures.
- Region semantics become mode-dependent when monitor inspection is unavailable, so request/response metadata must make it obvious whether coordinates were resolved against a real monitor or the combined desktop space.
- MCP transport expectations for native binary image payloads are not yet documented in this repository, so the implementor may need to extend transport models to represent image content explicitly and use base64 only as a compatibility fallback.
- Hyprland monitor inspection details may depend on `hyprctl` JSON shape, which should be treated as external input and validated carefully.
- Packaging and runtime capability checks can diverge if Linux dependencies are added in Nix but local non-Nix runs are still possible.

## Edge cases

- Missing `grim` on PATH.
- Non-Linux runtime where the tool is present but must return unsupported.
- Not running under Wayland or missing required environment variables.
- Region extends beyond output bounds.
- Region extends beyond combined desktop bounds in fallback mode.
- Region has zero or negative width or height.
- Unknown monitor selector.
- Multiple active monitors with different sizes, positions, and numbering order.
- Multiple active monitors where no primary/default marker is present and deterministic alphabetical/numeric fallback must be applied.
- No active outputs reported by Hyprland.
- Hyprland monitor inspection unavailable while `grim` still supports a compositor-wide screenshot.
- Screenshot command succeeds but returns empty output.
- Temporary-file cleanup after command failure.

## Validation recommendations

These are recommendations for later `scenario-validator` work only; this spec does not create or modify scenario files.

- Default scenario: full-output screenshot on a Linux Hyprland session returns PNG content and metadata for the selected monitor, or for the default/main monitor when no monitor is specified.
- Default scenario: when Hyprland monitor inspection is unavailable but compositor-wide capture still works, no-monitor capture returns one combined PNG image with metadata that marks it as a synthetic combined-output fallback.
- Default scenario: region screenshot with valid bounds returns a PNG artifact whose reported bounds match the requested region.
- Default scenario: when monitor inspection is unavailable, region screenshot treats requested coordinates as combined-desktop global bounds and reports that interpretation in metadata.
- Default scenario: display-info tool returns at least one active output with monitor number, origin, width, and height.
- Default scenario: invalid region request is rejected with a clear error and does not produce an artifact.
- Default scenario: non-Linux runtime returns a structured unsupported result while leaving the tool available.
- Default scenario: unsupported Linux environment or missing dependency returns a clear failure mode.
- If multi-monitor support is implemented in the first pass, add a scenario confirming default-monitor resolution and monitor numbering are unambiguous.

## Validation plan

- Review adapter boundaries to confirm MCP tool handlers do not contain raw shell-command sprawl.
- Verify Linux packaging adds `grim` while non-Linux runtimes keep the tool available and return unsupported.
- Confirm default-monitor resolution is explicit and deterministic when the caller omits `monitor`.
- Confirm deterministic default-monitor ordering uses Hyprland monitor data first, then numeric/alphabetical fallback when no primary/default marker is present.
- Confirm the no-monitor fallback path captures all outputs as one combined image when Hyprland monitor inspection is unavailable.
- Confirm the region fallback path treats `x`/`y` as combined-desktop global coordinates when monitor inspection is unavailable.
- Confirm the screenshot tool validates region input before invoking external commands.
- Confirm returned screenshot data uses the transport's binary-capable response shape, with metadata including image format, monitor identity/number, and capture bounds.
- Confirm display inspection returns structured numbering and geometry rather than free-form text.
- Confirm tests cover success and failure paths for validation, dependency, and environment errors.
