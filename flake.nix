{
  description = "Dark-factory MCP server bootstrap for Hyprland validation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      overlays.default = final: prev: {
        hyprland-mcp = self.packages.${prev.system}.default;
      };

      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./nix/package.nix {
          version = "0.1.0-bootstrap";
        };
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.system}.default}/bin/hyprland-mcp";
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            gitMinimal
            jq
            nixfmt-rfc-style
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);

      nixosModules.default = import ./nix/modules/nixos.nix self;
      darwinModules.default = import ./nix/modules/darwin.nix self;
    };
}
