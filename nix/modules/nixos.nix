self:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.hyprland-mcp;
in
{
  options.programs.hyprland-mcp = {
    enable = lib.mkEnableOption "the bootstrap Hyprland MCP package";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.default;
      description = "Package to install for the Hyprland MCP bootstrap project.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
