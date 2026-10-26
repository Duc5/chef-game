# Design decisions and interpretation of the brief

These are the implementation choices made without needing additional design input.

1. The later, detailed three-ingredient specification takes precedence over the early Frostglass Salt idea. Salt and cooking are omitted from this prototype.
2. The later forest specification takes precedence over the early stone-placement idea: the oak always falls towards the island after three hits. The nearby axe and stones can be examined; neither is a required inventory item.
3. Each region is a 960x768 handcrafted space on a 16px grid, viewed through a 640x360 viewport. Signpost interactions perform transitions. The village remains the central hub, and its four routes are available immediately.
4. A saved time-based seed chooses among three forest crossing x positions, three updraft patterns, and three furnace arrangements. It does not randomise the overall map. All wind patterns are traversed by the native physics test.
5. Wind is a top-down simulated height mechanic: jumping lifts the sprite while its shadow remains on the ground. Entering a current while airborne raises the chef to a fixed 28px hover plane. Space launches a separate jump from a gust; hovering never accumulates upward speed. Three staggered patterns span a wider chasm, with gaps that require jumping and sideways steering. The camera follows half the visual lift to keep the airborne chef framed. Currents reveal temporarily for six seconds after a stone enters them. Stones are unlimited, with a second supply at the ledge lip for convenient retries.
6. A 0.18-second active spatula swing and 0.4-second attack cooldown provide the first reflection timing target. Fireballs travel at 64px/sec; reflected fire travels at 150px/sec and follows mouse aim. Dodging lasts 0.22 seconds at 240px/sec; normal movement is 92px/sec.
7. Barklings use a simple pursuit/contact-damage pattern. Ash Imps telegraph shots with a bright ring, then shoot at the chef. The furnace spout also telegraphs and never runs out of shots.
8. Default health is three hearts. On death or a fall, checkpoint respawn restores health and preserves quest progress. Reload also restores health. Stone carrying is not saved.
9. The minimap reveals circular grid areas within six tiles, without wall occlusion. NPCs and points of interest only appear after their cells have been discovered. Discovery stays saved per region.
10. The invitation and some repeated NPC responses are condensed for readable dialogue pages. The main first-conversation dialogue is extracted from the supplied brief. Characters still speak at the player's pace. There are no branching dialogue choices.
11. The source pack is CC0. No secondary environment pack is mixed in. New puzzle art is editable pixel-grid SVG; chef clothing and spatula use code-drawn shapes over the supplied animated body, matching its palette and pixel density. Terrain and parchment UI are custom. This is the first artwork pass, not a claim of final production art.
12. Regional music and effects come from Ninja Adventure. A quiet procedural footstep is original. The pause menu includes an audio toggle. Music continues during menus and paced conversation.
13. The Royal Kitchen is a small interior rather than a castle. Presenting the ingredients displays their sprites on the counter, plays the supplied ending conversation, then fades to the prototype completion screen. There is no cooking minigame.
14. The playable portable package uses the supplied Godot runtime plus an exported PCK because standard export templates were absent. No installation or network connection is needed to play it. The source includes a conventional Windows export preset for later use with matching templates.

The original prompt is preserved verbatim as `original_brief.txt` for future iterations. Starting a new journey currently replaces the single save; multiple save slots and a confirmation dialog are later UX work.

## Playtest revision — wind and feedback

Based on player feedback, automatic stone-pickup, wind-discovery, reflected-fire and furnace-progress messages were removed. Feedback is visual and audible; explicit inspection, NPC dialogue and requested H hints remain available. The gap layout now uses non-overlapping 24px-radius gusts with sideways offsets, and a 175px/sec jump impulse from hover. A long stone throw can test distant currents from the ledge. Both new saves and older mountain saves inside the expanded chasm load safely on the new ledge without clearing quest progress.
