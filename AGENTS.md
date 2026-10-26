# Project conventions

Keep this a native Godot 4 project. Use typed GDScript, reusable scenes and small local systems. Terrain must use TileMapLayer. Preserve stable save IDs and keep quests optional with respect to NPC conversations. No cooking or fourth ingredient without a new user request.

Read docs/original_brief.txt and docs/design_decisions.md before changing game scope. Do not replace region scenes with a single giant gameplay script. Keep source-pack licences and the asset manifest. New pixels must match the established density and palette.

Run the native integration scene for gameplay/persistence changes; run visual_review for art/layout changes. Map generation overwrites hand edits in scenes/regions, so use it deliberately. Tests run with their own save filenames and disable ordinary saves. Do not delegate work unless the user explicitly asks.
