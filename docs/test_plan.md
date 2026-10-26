# Validation

The native integration scene runs inside Godot 4.7.2 with real physics and loaded autoloads. It exercises actual movement input, a real attack Area2D overlap, timed projectile reflection, wind-field traversal, collision removal, state idempotency, saves and ending transitions. The full result list is `test_results.txt`.

Automated validation includes opening the letter and paced dialogue; closing a conversation with E without retriggering it; jump landing; interaction targeting; exactly three tree hits; physical river traversal; state preservation across region travel; unlimited stones; thrown-stone reveal; airborne lift; failed-jump recovery; all three seeded wind layouts; furnace rejection of melee; incoming-fireball reflection; projectile activation of all switches; a permanent fire supply after imp death; all ingredients; respawn health and progress; atomic save/load; safe loading from a midair save; discovery persistence; and prototype completion.

`visual_review.tscn` renders the real OpenGL viewport and saves screenshots of the title, village, journal, forest, mountains, volcano and kitchen. Those images were inspected, followed by a custom art and UI-spacing pass. The native OpenGL run checks that imported textures, font, SVGs, shader and audio load on the Intel Iris Xe renderer. Headless tests deliberately skip audio allocation.

The exported PCK is tested using the bundled runtime from a working directory outside the project. The `--smoke` startup marker confirms that the packaged main scene, village, player, HUD and JSON dialogue load successfully; stderr is checked for errors. The final executable is also opened in graphical mode.

Manual follow-up: try varied mouse/keyboard play styles and screen sizes; tune combat and platforming difficulty; verify preferred sound volume; expand accessibility and input remapping before any commercial release. Automated tests do not establish final balance, performance on other GPUs, or final artwork quality.

Wind feedback regression: the expanded suite checks 15 seconds of bounded hovering, visible camera framing, all three staggered routes with actual jump input, rejection of holding-W and walking shortcuts, silent pickup/reveal/reflection feedback, and safe loading of legacy mountain positions. Updated OpenGL captures include wind_hover.png, wind_jump.png and mountains.png.
