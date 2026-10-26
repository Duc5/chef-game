extends Node
const WindRules = preload("res://scripts/puzzles/wind_course.gd")
var game: Node2D

func _ready() -> void:
	call_deferred("capture")

func shot(name_text: String) -> void:
	for i: int in range(8): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/"+name_text+".png")

func capture() -> void:
	State.save_enabled = false
	State.reset()
	game = preload("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	await shot("title")
	game.new_game()
	game.hud.toast_timer = 0
	game.region.clock = 4
	game.chef.get_node("Camera2D").position_smoothing_enabled = false
	await shot("village")
	State.set_flag("letter")
	game.hud.toast_timer = 0
	game.hud.set_mode("journal")
	await shot("journal")
	game.hud.set_mode("none")
	game.load_region("forest",Vector2(480,452))
	await shot("forest")
	game.load_region("mountains",WindRules.CHECKPOINT)
	game.hud.toast_timer = 0
	game.chef.position = game.region.get_node("Wind0").position
	game.chef.height = 8
	for i: int in range(240): await get_tree().physics_frame
	await shot("wind_hover")
	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")
	for i: int in range(28): await get_tree().physics_frame
	await shot("wind_jump")
	game.load_region("mountains",WindRules.CHECKPOINT)
	game.chef.position = game.region.get_node("Wind1").position
	game.chef.height = WindRules.HOVER_HEIGHT
	for i: int in range(3): game.region.get_node("Wind%d"%i).reveal()
	await shot("mountains")
	game.load_region("volcano",Vector2(480,393))
	await shot("volcano")
	game.load_region("kitchen",Vector2(480,350))
	await shot("kitchen")
	print("VISUAL_CAPTURE_OK")
	game.queue_free()
	await get_tree().process_frame
	get_tree().quit()
