# Copilot Instructions for Simple Platformer

This project is a Godot 4.x 2D platformer focused on tight movement, collectible progression, and scene-based state management.

## What to prioritize

- Keep gameplay changes small and modular.
- Prefer GDScript with typed variables and `@export` for tunable gameplay values.
- Use signals for cross-node communication instead of tightly coupling nodes.
- Put new logic into dedicated scripts rather than expanding `main.gd`.
- Use `@onready` node references and avoid repeated `get_node()` lookups.

## Project conventions

- Player interactions use the `player` group and Area2D collisions.
- `ConfigFile` persistence is used for settings, high score, and selected level.
- The scene tree uses a title screen, level select, and main gameplay scene.
- Reuse `create_tone()` for procedural sound effects when adding audio.

## Avoid

- Duplicating audio helper logic across scripts.
- Using `_process()` for physics or movement updates.
- Hardcoding child indexes like `get_child(1)` for visual nodes.
- Putting all gameplay state into `main.gd`.

## Prompt guidance

- When asked to build a feature, mention the relevant scene and script file(s).
- When changing UI or flow, include the scene path and the node(s) involved.
- Prefer edits that preserve existing signals and scene structure.

## Existing custom agent

- This project already defines a `godot-dev` custom agent in `.github/agents/game.agent.md`.
- Use that agent for gameplay, scene, and GDScript tasks whenever possible.
