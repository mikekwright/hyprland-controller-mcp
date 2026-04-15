# Nix Integration

This repository provides a Nix flake for development and installation.

## Outputs

- `packages.<system>.default`
- `apps.<system>.default`
- `devShells.<system>.default`
- `overlays.default`
- `nixosModules.default`
- `darwinModules.default`

## What the package contains today

The bootstrap package installs wrapper commands for the tracked shell entrypoints:

- `hyprland-mcp`
- `hyprland-mcp-validate`
- `hyprland-mcp-check`

These are bootstrap placeholders and do not yet start a functioning MCP server.

## NixOS example

```nix
{
  inputs.hyprland-mcp.url = "github:your-org/hyprland-mcp-dark-factory";

  outputs = { self, nixpkgs, hyprland-mcp, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        hyprland-mcp.nixosModules.default
        {
          programs.hyprland-mcp.enable = true;
        }
      ];
    };
  };
}
```

## nix-darwin example

```nix
{
  inputs.hyprland-mcp.url = "github:your-org/hyprland-mcp-dark-factory";

  outputs = { self, nix-darwin, hyprland-mcp, ... }: {
    darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        hyprland-mcp.darwinModules.default
        {
          programs.hyprland-mcp.enable = true;
        }
      ];
    };
  };
}
```

## Runtime note

The actual runtime target remains Linux with Hyprland. The darwin module is useful for development machines and shared packaging workflows, not for desktop validation execution.
