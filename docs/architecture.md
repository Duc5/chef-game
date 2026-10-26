# Architecture

`scenes/main.tscn` owns the chef, current region and HUD. `main.gd` only coordinates lifecycle, region transitions and new/continue actions. Region layouts are saved scenes; the game does not generate entire maps at runtime.

| System | Public interface / signals | Dependencies and extension |
| --- | --- | --- |
| State autoload | `changed`, `notified`, `dialogue_requested`, `travel_requested`, `ending_requested`; `collect`, `set_flag`, `save_game`, `load_game` | Owns persistent domain state and data dialogue; no node references in saves. Add stable IDs and resource definitions for more content. |
| Sound autoload | `region`, `effect`, `toggle` | Owns short-lived sound players and regional music. Skips playback allocation in headless runs. |
| ChefPlayer | `attack`, `throw_rock`, `take_damage`, `respawn`; `fell` | CharacterBody2D movement; generic Health and Interaction children; independent from quest-specific puzzle scripts. Exposed speed values support tuning. |
| InteractionComponent | `scan`, `activate`; `target_changed` | Chooses nearest eligible member of `interactable`, with facing bias. One shared shader implements sprite outlines. |
| FeastInteractable | `eligible`, `prompt`, `highlight`, `interact` | Exported content properties; NPC, letter, stone pile, gate and ingredient roles. Stable flags gate ingredients where necessary. |
| HealthComponent | `hurt`, `restore`; `changed`, `depleted` | Reused by chef and enemies. Damage invulnerability prevents a single swing causing repeated damage. |
| Combat | Area2D attack receiver; `receive_hit(direction, reflected)` | The same interface receives melee and reflected projectiles. Projectiles change allegiance and direction after reflection. Normal melee cannot awaken a furnace. |
| Tree puzzle | `receive_hit`; `puzzle_completed` | Owns three-hit progression and `forest_bridge` stable state. Region observes the flag to remove river collision and reveal the bridge. No dependency on quest inventory. |
| Wind puzzle | `Updraft.reveal`; height / vertical-speed fields | Stone flight reveals local fields; the chef controller converges to a fixed hover plane while supported. Space launches a ballistic hop; the takeoff gust does not recapture the chef until they leave it or descend. Shared WindCourse constants own geometry, hover height, radius and seeded patterns. Region owns chasm hazard and safe ledge recovery. |
| Furnace puzzle | `receive_hit`; `activated` | Tracks three stable furnace IDs and unlocks `greenhouse_open`. Region removes the physical gate. The permanent spout is independent from imp survival. |
| Region | exported `region_id`, `sync` | Owns local checkpoints, hazards, seeded arrangement selection and atmospheric animation. TileMapLayer + sprite + StaticBody2D nodes remain editable in the scene. |
| HUD | `new_game_requested`, `continue_requested`; `open_dialogue`, `set_mode` | Observes domain state and renders UI. UI lock blocks gameplay; a two-frame input grace prevents closing dialogue from reopening an NPC or swinging behind a menu. |
| IngredientData | Resource fields for ID, name, region, clue, icon | `.tres` resources supply the journal and icon strip. The prototype has a three-item registry in State. |

Global state is limited to persistent State and audio service Sound. Quests use unique ingredient IDs, flags use stable puzzle IDs, and maps use region IDs plus integer cell keys. Changes emit State.changed; presentation never decides whether a combat hit is valid.

Save files are versioned JSON written to a temporary file then renamed. Ingredient insertion is idempotent. Region travel saves after placing the chef at a safe entrance. Chasm saves normalise the respawn point to the ledge. Health is intentionally restored on reload and respawn. The held stone is transient; every stone supply replenishes.

To add another NPC: instance the generic interactable, choose kind `npc`, assign a stable ID and texture, then add dialogue arrays to `data/dialogues/story.json`. To add another ingredient: create an IngredientData resource, register its ID in State, place a generic ingredient scene and add any local puzzle script. The current three-slot HUD/end condition should be expanded if increasing the prototype's ingredient count; player movement and combat need no changes.

Source scenes use a normal attack Area2D and DamageReceiver Area2Ds on physics layer 3. Player/world use layers 2/1. Moving fireballs evaluate the shared receiver interface over the `damageable` group and use a small distance threshold at the fixed 60 Hz physics step. Their maximum step is 2.5 pixels, below receiver radii, so collision tunnelling is avoided at the configured speed.
