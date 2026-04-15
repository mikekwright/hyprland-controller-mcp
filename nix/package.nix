{
  lib,
  makeWrapper,
  stdenvNoCC,
  version,
}:

stdenvNoCC.mkDerivation {
  pname = "hyprland-mcp";
  inherit version;
  src = ./..;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/libexec/hyprland-mcp"
    install -d "$out/share/doc/hyprland-mcp"
    install -d "$out/bin"

    install -m755 "$src/scripts/run-server.sh" "$out/libexec/hyprland-mcp/run-server.sh"
    install -m755 "$src/scripts/validate-scenario.sh" "$out/libexec/hyprland-mcp/validate-scenario.sh"
    install -m755 "$src/scripts/check.sh" "$out/libexec/hyprland-mcp/check.sh"
    install -m644 "$src/README.md" "$out/share/doc/hyprland-mcp/README.md"

    makeWrapper "$out/libexec/hyprland-mcp/run-server.sh" "$out/bin/hyprland-mcp"
    makeWrapper "$out/libexec/hyprland-mcp/validate-scenario.sh" "$out/bin/hyprland-mcp-validate"
    makeWrapper "$out/libexec/hyprland-mcp/check.sh" "$out/bin/hyprland-mcp-check"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bootstrap package for a dark-factory Hyprland MCP server repository";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "hyprland-mcp";
  };
}
