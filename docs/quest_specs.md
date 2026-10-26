# Prototype quest specification

| Quest | Discovery | Interaction / solution | Persistent completion |
| --- | --- | --- | --- |
| Royal invitation | Pigeon circles the cottage and drops an envelope | E opens player-paced letter; J reopens journal and invitation | `letter`, conversation history |
| Dewcrown Mushroom | Optional Rowan and Bram clues; distinctive brittle riverside oak | Three separate whacks; attack Area2D hits tree receiver; fallen trunk replaces river gap collision | `tree_hits`, `forest_bridge`, inventory `mushroom` |
| Skyfeather Egg | Optional Mira clue, chimes, stones at chasm edge | E picks up renewable stone; RMB throws; current reveals six seconds; Space enters a fixed-height hover; Space and WASD hop between three separated, staggered updrafts | Saved pattern seed, `wind_discovered`, inventory `egg` |
| Cinderheart Pepper | Optional Flint clue and forge inscription | Spatula reflects incoming fire towards mouse; three emblems require reflected shots; door collision is removed | `furnace_0..2`, `greenhouse_open`, inventory `pepper` |
| Return to Royal Kitchen | Kitchen accessible from village at any time | E at preparation counter checks all three IDs, displays items and begins paced ending | `presented`, `completed` |

NPCs are optional. Ingredients cannot duplicate in inventory. Previously collected items disappear from their region. Defeated named enemies stay defeated. The furnace spout and stone supplies remain available indefinitely. Forest bridge and forge opening persist across travel and saves. The minimap stores discovered cells independently for every region. H exposes three progressively explicit hints near each main puzzle; hints do not alter completion.

No ingredient is spent during this stage. All collection orders are allowed. A kitchen visit before completion reports missing progress without trapping the chef or consuming items. The final display deliberately ends before cooking.
