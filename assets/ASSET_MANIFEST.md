# Asset manifest

Main source: Ninja Adventure by Pixel-boy and AAA. The supplied LICENSE.txt declares CC0 1.0 Universal. Selected originals are preserved under `source/ninja_adventure/`; that directory is excluded from runtime imports with `.gdignore`. No Kenney assets were required.

| Runtime file | Original pack file | Dimensions / frames | Modification |
| --- | --- | --- | --- |
| `game/floor.png` | `Backgrounds/Tilesets/TilesetFloor.png` | [352, 417]; frames 16px atlas grid; objects span multiple cells | Unmodified |
| `game/nature.png` | `Backgrounds/Tilesets/TilesetNature.png` | [384, 336]; frames 16px atlas grid; objects span multiple cells | Unmodified |
| `game/house.png` | `Backgrounds/Tilesets/TilesetHouse.png` | [528, 368]; frames 16px atlas grid; objects span multiple cells | Unmodified |
| `game/interior.png` | `Backgrounds/Tilesets/Interior/TilesetInterior.png` | [256, 320]; frames 16px atlas grid; objects span multiple cells | Unmodified |
| `game/font.ttf` | `Ui/Font/NormalFont.ttf` | Audio/font | Unmodified |
| `game/rowan.png` | `Actor/Character/OldMan/SpriteSheet.png` | [64, 112]; frames [16, 16] | Unmodified |
| `game/mira.png` | `Actor/Character/Eskimo/SpriteSheet.png` | [64, 112]; frames [16, 16] | Unmodified |
| `game/flint.png` | `Actor/Character/GladiatorBlue/SpriteSheet.png` | [64, 112]; frames [16, 16] | Unmodified |
| `game/bram.png` | `Actor/Character/Hunter/SpriteSheet.png` | [64, 112]; frames [16, 16] | Unmodified |
| `game/quill.png` | `Actor/Character/Noble/SpriteSheet.png` | [64, 112]; frames [16, 16] | Unmodified |
| `game/child.png` | `Actor/Character/Child/SpriteSheet.png` | [64, 32]; frames [16, 16] | Unmodified |
| `game/imp.png` | `Actor/Character/Flam/SpriteSheet.png` | [64, 112]; frames [16, 16] | Unmodified |
| `game/village.ogg` | `Audio/Musics/4 - Village.ogg` | Audio/font | Unmodified |
| `game/forest.ogg` | `Audio/Musics/11 - Clearing.ogg` | Audio/font | Unmodified |
| `game/mountains.ogg` | `Audio/Musics/22 - Dream.ogg` | Audio/font | Unmodified |
| `game/volcano.ogg` | `Audio/Musics/30 - Ruins.ogg` | Audio/font | Unmodified |
| `game/kitchen.ogg` | `Audio/Musics/5 - Peaceful.ogg` | Audio/font | Unmodified |
| `game/whack.wav` | `Audio/Sounds/Whoosh & Slash/Whoosh.wav` | Audio/font | Unmodified |
| `game/collect.wav` | `Audio/Jingles/Secret1.wav` | Audio/font | Unmodified |
| `game/reflect.wav` | `Audio/Jingles/Secret2.wav` | Audio/font | Unmodified |
| `game/talk.wav` | `Audio/Sounds/Alert/Alert.wav` | Audio/font | Unmodified |
| `game/idle.png` | `Actor/CharacterAnimated/NinjaGreen/Separate/Idle.png` | [128, 128]; frames [32, 32] | Unmodified |
| `game/walk.png` | `Actor/CharacterAnimated/NinjaGreen/Separate/Walk.png` | [128, 128]; frames [32, 32] | Unmodified. Chef costume and spatula are code-drawn overlays. |
| `game/attack.png` | `Actor/CharacterAnimated/NinjaGreen/Separate/Attack.png` | [128, 128]; frames [32, 32] | Unmodified |
| `game/roll.png` | `Actor/CharacterAnimated/NinjaGreen/Separate/Roll.png` | [128, 96]; frames [32, 32] | Unmodified |
| `game/jump.png` | `Actor/CharacterAnimated/NinjaGreen/Separate/Jump.png` | [96, 128]; frames [32, 32] | Unmodified |
| `game/pickup.png` | `Actor/CharacterAnimated/NinjaGreen/Separate/Pickup.png` | [32, 64]; frames [32, 32] | Unmodified |
| `game/hit.png` | `Actor/CharacterAnimated/NinjaGreen/Separate/Hit.png` | [128, 64]; frames [32, 32] | Unmodified |
| `game/jump.wav` | `Audio/Sounds/Jump & Bounce/Jump.wav` | Audio/font | Unmodified |
| `game/fireball.wav` | `Audio/Sounds/Elemental/Fireball.wav` | Audio/font | Unmodified |

## Original project artwork

| File | Dimensions / intended use |
| --- | --- |
| `custom/bridge.svg` | 32 x 128; editable pixel-grid SVG |
| `custom/counter.svg` | 80 x 32; editable pixel-grid SVG |
| `custom/door.svg` | 64 x 48; editable pixel-grid SVG |
| `custom/egg.svg` | 32 x 32; editable pixel-grid SVG |
| `custom/letter.svg` | 32 x 32; editable pixel-grid SVG |
| `custom/mushroom.svg` | 32 x 32; editable pixel-grid SVG |
| `custom/pepper.svg` | 32 x 32; editable pixel-grid SVG |
| `custom/rock.svg` | 32 x 32; editable pixel-grid SVG |
| `custom/spout.svg` | 32 x 32; editable pixel-grid SVG |
| `custom/switch.svg` | 32 x 32; editable pixel-grid SVG |
| `custom/terrain.svg` | 128 x 16; editable pixel-grid SVG |
| `custom/footstep.wav` | Original synthesised short footfall, mono 22,050 Hz |
| `scripts/player/chef_art.gd` | Original code-drawn chef hat, face, coat, apron and spatula; layers on pack animation |
| `scripts/world/region.gd` | Original code-drawn pigeon, ripples, wind chimes, snow and embers |
| `scripts/ui/hud.gd` | Original framed parchment/slate UI; uses the pack pixel font |

Terrain SVG consists of eight 16px tiles. Separate idle/walk/attack/roll/jump sheets use four direction rows. Static NPC/enemy sheets use the first 16px cell for their idle appearance. Map sprite region rectangles are visible in the saved scenes and world builder. Water, snow, lava, bridge, forge door and item visuals are custom rather than falsely attributed to missing pack artwork.

## Reference project inspection

The supplied Godot Project V4 ZIP was inspected for the TileSet atlas structure and character scene composition. Its sample gameplay code and embedded .git repository were not copied into this project.