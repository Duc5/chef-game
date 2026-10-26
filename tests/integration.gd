extends Node
const WindRules = preload("res://scripts/puzzles/wind_course.gd")
## Run as a scene so Godot loads real autoloads, physics and resources.
var failures: int = 0
var checks: int = 0
var game: Node2D
var chef: ChefPlayer
var reports: Array[String] = []
var notifications: Array[String] = []
var falls: int = 0

func _ready() -> void:
	call_deferred("run")

func verify(condition: bool, message: String) -> void:
	checks += 1
	if not condition: failures += 1
	var line: String = ("PASS " if condition else "FAIL ")+message
	reports.append(line)
	print(line)

func frames(count: int = 3) -> void:
	for i: int in range(count):
		await get_tree().physics_frame
		await get_tree().process_frame

func aim_at(world_position: Vector2) -> void:
	chef.get_node("Camera2D").reset_smoothing()
	chef.get_node("Camera2D").force_update_scroll()
	var motion := InputEventMouseMotion.new()
	motion.position = get_viewport().get_canvas_transform()*world_position
	get_viewport().push_input(motion)

func release_movement() -> void:
	for action: String in ["left","right","up","down"]:
		Input.action_release(action)

func jump_once() -> void:
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")

func steer_to(target: Vector2, timeout: int = 160) -> bool:
	var original_falls: int = falls
	for i: int in range(timeout):
		if falls != original_falls:
			release_movement()
			return false
		if chef.position.distance_to(target) < 5:
			release_movement()
			return true
		var offset: Vector2 = target-chef.position
		release_movement()
		if offset.y < -3: Input.action_press("up")
		if offset.y > 3: Input.action_press("down")
		if offset.x < -3: Input.action_press("left")
		if offset.x > 3: Input.action_press("right")
		await frames(1)
	release_movement()
	return false

func run() -> void:
	State.save_enabled = false
	game = preload("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	game.new_game()
	chef = game.chef
	chef.fell.connect(func() -> void: falls += 1)
	State.notified.connect(func(message: String) -> void: notifications.append(message))
	await frames()
	verify(game.region.get_node("Terrain") is TileMapLayer,"Editable TileMapLayer terrain loads")
	verify(chef.health.current == 3,"Chef begins with three hearts")
	await frames(190)
	verify(game.region.get_node("Letter").visible,"Pigeon delivers interactable letter")
	game.region.get_node("Letter").interact(chef)
	verify(State.flags.get("letter",false) and game.hud.mode == "dialogue","Opening letter unlocks paced dialogue and journal")
	while game.hud.mode == "dialogue": game.hud.advance()
	chef.position = Vector2(424,391)
	chef.interaction.scan(chef,Vector2.UP)
	game.region.get_node("Rowan").interact(chef)
	while game.hud.line_index < game.hud.lines.size()-1: game.hud.advance()
	var e_key := InputEventKey.new()
	e_key.physical_keycode = KEY_E
	e_key.keycode = KEY_E
	e_key.pressed = true
	Input.parse_input_event(e_key)
	await frames(3)
	e_key.pressed = false
	Input.parse_input_event(e_key)
	verify(game.hud.mode == "none","Closing dialogue with E does not reopen the same NPC")
	var before: Vector2 = chef.position
	Input.action_press("right")
	await frames(25)
	Input.action_release("right")
	verify(chef.position.x > before.x+20,"WASD input moves the physics body")
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
	verify(chef.height > 0,"Jump raises the chef above the shadow plane")
	await frames(60)
	verify(chef.height == 0,"Jump returns safely to ground")
	var history_count: int = State.discovered.village.size()
	verify(history_count > 100,"Discovery mask reveals nearby map cells")
	game.travel("forest")
	await frames()
	var tree: Node2D = game.region.get_node("WeakenedOak")
	chef.position = Vector2(game.region.bridge_x,441)
	chef.interaction.scan(chef,Vector2.UP)
	verify(chef.interaction.target == tree and tree.selected,"Nearest interaction selects and outlines weakened oak")
	aim_at(tree.global_position+Vector2(0,-10))
	Input.action_press("attack")
	await frames(4)
	Input.action_release("attack")
	verify(tree.hits == 1,"Left-click attack hitbox physically strikes the tree")
	tree.receive_hit(Vector2.UP,false)
	verify(not State.flags.get("forest_bridge",false),"Two spatula hits leave bridge unsolved")
	tree.receive_hit(Vector2.UP,false)
	await frames()
	verify(State.flags.get("forest_bridge",false) and game.region.get_node("RiverGap/Collision").disabled,"Third hit makes river gap physically traversable")
	tree.receive_hit(Vector2.UP,false)
	verify(tree.hits == 3,"Repeated attacks do not repeat puzzle completion")
	chef.position = Vector2(game.region.bridge_x,430)
	Input.action_press("up")
	await frames(125)
	Input.action_release("up")
	verify(chef.position.y < 290,"Chef can physically walk across the fallen bridge")
	game.region.get_node("Mushroom").interact(chef)
	verify("mushroom" in State.inventory,"Mushroom collection updates inventory")
	verify(not State.collect("mushroom") and State.inventory.size() == 1,"Ingredient collection is idempotent")
	game.travel("village")
	await frames()
	verify(State.discovered.village.size() >= history_count,"Map exploration survives region transitions")
	game.travel("forest")
	await frames()
	verify(game.region.get_node("FallenBridge").visible,"Fallen tree persists after returning to region")
	game.travel("village")
	game.travel("mountains")
	await frames()
	notifications.clear()
	game.region.get_node("RockPile").interact(chef)
	verify(State.has_rock,"Loose stones can be picked up")
	verify(notifications.is_empty(),"Picking up a stone produces no tutorial pop-up")
	chef.position = game.region.get_node("Wind0").position+Vector2(0,68)
	chef.aim = Vector2.UP
	chef.throw_rock()
	await frames(25)
	verify(State.flags.get("wind_discovered",false),"Thrown rock reveals a hidden current")
	verify(notifications.is_empty(),"Wind discovery uses visual feedback without a pop-up")
	game.region.get_node("RockPile").interact(chef)
	verify(State.has_rock,"Rock supply replenishes")
	State.save_enabled = true
	State.chef_position = Vector2(480,340)
	State.save_game("user://midair_test.json")
	State.load_game("user://midair_test.json")
	verify(State.chef_position == WindRules.CHECKPOINT,"Midair save reloads at a safe ledge")
	var legacy_file := FileAccess.open("user://legacy_wind.json",FileAccess.WRITE)
	legacy_file.store_string(JSON.stringify({"version":1,"region":"mountains","position":[480,450]}))
	legacy_file.close()
	State.load_game("user://legacy_wind.json")
	verify(State.chef_position == WindRules.CHECKPOINT,"Old mountain saves migrate safely to the new ledge")
	# Restore the integration journey after inspecting the deliberately minimal legacy save.
	State.load_game("user://midair_test.json")
	State.save_enabled = false
	chef.position = game.region.get_node("Wind0").position
	chef.height = 8
	chef.vertical_speed = 0
	await frames(30)
	verify(is_equal_approx(chef.height,WindRules.HOVER_HEIGHT) and chef.vertical_speed == 0,"Wind lifts chef to a fixed hover height")
	await frames(900)
	verify(is_equal_approx(chef.height,WindRules.HOVER_HEIGHT) and chef.hovering,"Hover stays bounded after fifteen seconds in a gust")
	var screen_head: Vector2 = get_viewport().get_canvas_transform()*(chef.global_position+Vector2(0,-chef.height-30))
	verify(Rect2(0,36,640,301).has_point(screen_head),"Camera keeps the hovering chef visible in the play area")
	chef.position = Vector2(600,340)
	chef.height = 0
	await frames(2)
	verify(chef.position.distance_to(chef.checkpoint)<5,"Failed chasm crossing returns to checkpoint")
	verify("mushroom" in State.inventory,"Falling retains quest progress")
	# Check straight-line and no-jump shortcuts, then perform the intended hops.
	for pattern: int in range(3):
		State.seed_value = pattern
		game.load_region("mountains",WindRules.CHECKPOINT)
		await frames()
		var first: Node2D = game.region.get_node("Wind0")
		chef.position = first.position
		chef.height = WindRules.HOVER_HEIGHT
		await frames(3)
		var previous_falls: int = falls
		Input.action_press("up")
		await frames(100)
		release_movement()
		verify(falls > previous_falls and chef.position.y > WindRules.CHASM_TOP,"Holding W cannot cross wind pattern %d"%pattern)
		chef.position = first.position
		chef.height = WindRules.HOVER_HEIGHT
		chef.vertical_speed = 0
		await frames(3)
		var walked_across: bool = await steer_to(game.region.get_node("Wind1").position)
		verify(not walked_across,"Pattern %d requires a jump across the gap between gusts"%pattern)
		chef.position = WindRules.CHECKPOINT
		chef.height = 0
		chef.vertical_speed = 0
		await jump_once()
		var crossed: bool = true
		for i: int in range(3):
			var wind: Node2D = game.region.get_node("Wind%d"%i)
			if i > 0: await jump_once()
			if not await steer_to(wind.position):
				print("COURSE_DEBUG pattern=",pattern," gust=",i," position=",chef.position," height=",chef.height," hovering=",chef.hovering)
				crossed = false
				break
			await frames(20)
		if crossed:
			await jump_once()
			crossed = await steer_to(Vector2(480,180))
			if not crossed: print("COURSE_DEBUG landing pattern=",pattern," position=",chef.position," height=",chef.height)
			await frames(80)
		verify(crossed and chef.position.y < WindRules.CHASM_TOP and chef.height == 0,"Wind pattern %d can be completed by jumping between staggered gusts"%pattern)
	game.region.get_node("Egg").interact(chef)
	verify("egg" in State.inventory,"Egg can be collected without NPC prerequisites")
	game.travel("village")
	game.travel("volcano")
	await frames()
	verify(not game.region.get_node("GreenhouseBarrier/Collision").disabled,"Greenhouse begins sealed")
	var emblem: Node2D = game.region.get_node("Switch0")
	emblem.receive_hit(Vector2.UP,false)
	verify(not State.flags.get("furnace_0",false),"Normal melee cannot activate furnace switches")
	chef.position = Vector2(480,440)
	chef.attack_cooldown = 0
	aim_at(chef.position+Vector2(0,-100))
	var incoming: Node2D = preload("res://scenes/objects/projectile.tscn").instantiate()
	incoming.position = chef.position+Vector2(0,-28)
	incoming.direction = Vector2.DOWN
	game.region.add_child(incoming)
	Input.action_press("attack")
	await frames(3)
	Input.action_release("attack")
	verify(is_instance_valid(incoming) and incoming.reflected,"Timed attack physically reflects an incoming fireball")
	for i: int in range(3):
		emblem = game.region.get_node("Switch%d"%i)
		var fire: Node2D = preload("res://scenes/objects/projectile.tscn").instantiate()
		fire.position = emblem.position+Vector2(0,35)
		game.region.add_child(fire)
		notifications.clear()
		fire.reflect(Vector2.UP)
		verify(notifications.is_empty(),"Reflection produces no gameplay-covering pop-up")
		verify(fire.reflected and fire.direction == Vector2.UP,"Spatula reflection changes projectile allegiance and aim")
		await frames(20)
		verify(State.flags.get("furnace_%d"%i,false),"Reflected projectile activates furnace %d"%i)
	await frames()
	verify(State.flags.get("greenhouse_open",false) and game.region.get_node("GreenhouseBarrier/Collision").disabled,"Three switches open the greenhouse")
	var imp: Node2D = game.region.get_node_or_null("forge_imp")
	if imp != null:
		imp.health.invulnerability = 0
		imp.receive_hit(Vector2.RIGHT,true)
		imp.health.invulnerability = 0
		imp.receive_hit(Vector2.RIGHT,true)
	await frames(180)
	verify(game.region.has_node("Spout") and get_tree().get_nodes_in_group("projectile").size()>0,"Permanent spout still supplies fire after imp dies")
	game.region.get_node("Pepper").interact(chef)
	verify(State.all_collected(),"All three data-defined ingredients are collected")
	chef.health.invulnerability = 0
	chef.health.hurt(3)
	verify(chef.health.current == 3 and State.all_collected(),"Death restores health and retains all quest progress")
	State.save_enabled = true
	verify(State.save_game("user://integration_save.json"),"Atomic save succeeds")
	State.reset()
	verify(State.load_game("user://integration_save.json"),"Versioned save reload succeeds")
	verify(State.all_collected() and State.flags.get("forest_bridge",false) and State.flags.get("greenhouse_open",false),"Save restores ingredients and puzzle states")
	verify(State.discovered.has("village"),"Save restores persistent fog discovery")
	State.save_enabled = false
	game.load_region("kitchen",Vector2(480,330))
	await frames()
	game.region.get_node("PreparationCounter").interact(chef)
	verify(game.hud.ending_after_dialogue,"Returning ingredients triggers final cutscene")
	while game.hud.mode == "dialogue": game.hud.advance()
	verify(game.hud.mode == "ending" and State.flags.get("completed",false),"Final cutscene reaches prototype completion")
	var summary: String = "%d / %d checks passed"%[checks-failures,checks]
	print(summary)
	var out := FileAccess.open("res://docs/test_results.txt",FileAccess.WRITE)
	out.store_string("Godot 4.7.2 native integration suite\n"+"\n".join(reports)+"\n"+summary+"\n")
	out.close()
	game.queue_free()
	await frames(3)
	get_tree().quit(0 if failures == 0 else 1)
