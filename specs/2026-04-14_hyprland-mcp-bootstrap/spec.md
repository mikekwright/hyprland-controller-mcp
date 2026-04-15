# Hyprland MCP Bootstrap

## Problem

The repository needs a dark-factory structure before any MCP server implementation starts.

## Goals

- Establish a repository layout that separates specs, implementation, and validation.
- Define the four-agent workflow and permission model.
- Create bootstrap documentation and templates for the first implementation cycle.
- Add a Nix flake that exposes installable bootstrap outputs for NixOS and nix-darwin.

## Non-goals

- Implementing runtime MCP behavior
- Implementing Hyprland adapter logic

## Constraints

- Exactly four agents
- Validator isolated from implementation code
- Builder and implementor isolated from scenarios
- Installable through Nix without requiring application runtime implementation first

## Acceptance criteria

- Root bootstrap files exist
- Agent policy exists in `AGENTS.md` and `opencode.json`
- `specs/`, `src/`, and `scenarios/` are clearly separated
- Scenario artifact locations exist and are ignored appropriately
- A flake exposes package, app, dev shell, and host-module outputs
