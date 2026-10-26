# Chef Game: A Royal Feast

A 2D top-down adventure prototype made in Godot. Explore Bramblewick and its surrounding regions, solve environmental puzzles, and gather three ingredients for the King's birthday feast.

## Requirements

- **Godot 4.7.2**, standard edition. The .NET edition is not required.
- Git to clone the repository.

All required assets are included. No external add-ons are needed.

## Clone and open

Clone using this repository's URL:

```sh
git clone https://github.com/OWNER/REPOSITORY.git chef-game
cd chef-game
```

1. Open Godot's Project Manager and select **Import**.
2. Select `project.godot` in the cloned folder and open the project.
3. Wait for the initial asset import, then press **F5** to run the game. **F6** runs the currently open scene.

If Godot is on your PATH, you can also open the editor from the project root:

```sh
godot --editor --path .
```

The `.godot/` cache is generated locally and excluded from version control. The Windows helper scripts currently contain a local Godot executable path; use the Project Manager or commands above on other machines.

## Controls

| Action | Input |
| --- | --- |
| Move | WASD |
| Aim | Mouse |
| Attack / reflect | Left click |
| Dodge | Left Shift |
| Jump / hop from an updraft | Space |
| Interact / pick up stone | E |
| Throw stone | Right click |
| Optional hint | H |
| Journal | J |
| Map | M |
| Pause | Escape |

## Project structure

| Directory | Contents |
| --- | --- |
| `scenes/` | Main scene, player, regions, actors, objects, and UI |
| `scripts/` | Movement, combat, interactions, puzzles, world state, and UI logic |
| `data/` | Ingredient resources and dialogue |
| `assets/` | Runtime assets, custom artwork, and source-asset licences |
| `tests/` | Integration tests and viewport capture scenes |
| `docs/` | Architecture, quest specifications, design notes, and test results |
| `tools/` | Map-authoring utilities |

The entry scene is `scenes/main.tscn`. Region maps are editable scenes under `scenes/regions/` and use 16×16 TileMapLayers.

**Map generation is optional:** running `tools/build_world.tscn` overwrites the five region scenes. Normal editing and play use the saved scenes directly.

## Tests

With Godot on your PATH, run from the project root:

```sh
godot --headless --fixed-fps 60 --path . res://tests/integration.tscn
```

Alternatively, substitute the path to your Godot executable. Tests write results to `docs/test_results.txt`. See [the test plan](docs/test_plan.md) and [architecture](docs/architecture.md) for more detail.

## Builds

Executable builds are excluded from Git. Run the source project with F5, or use a separately distributed Windows build. Keep `RoyalFeast.exe` and `RoyalFeast.pck` together.

A `Windows Desktop` export preset is included. Install matching Godot export templates before creating a conventional Windows export.

## Credits

Artwork, pixel font, music, and selected sounds: **Ninja Adventure by Pixel-boy & AAA**, supplied under CC0. See [the asset manifest](assets/ASSET_MANIFEST.md) and `assets/source/ninja_adventure/LICENSE.txt`.

Custom chef costume, spatula, puzzle artwork, UI, and footsteps were created for this project. The game uses [Godot Engine](https://godotengine.org/), distributed under the [MIT licence](https://godotengine.org/license/).
