extends Node2D
var region: Node2D
@onready var chef: ChefPlayer = $Chef
@onready var hud: Control = $HUD/Canvas

func _ready() -> void:
	State.travel_requested.connect(travel)
	State.ending_requested.connect(func() -> void: hud.begin_ending())
	hud.new_game_requested.connect(new_game)
	hud.continue_requested.connect(continue_game)
	load_region("village",Vector2(280,500))
	State.controls_locked = true
	if "--smoke" in OS.get_cmdline_user_args():
		hud.mode = "none"
		State.controls_locked = false
		print("ROYAL_FEAST_READY: village, player, HUD and dialogue data loaded.")

func new_game() -> void:
	State.reset()
	load_region("village",Vector2(280,500))
	chef.health.restore()
	State.controls_locked = false
	hud.mode = "none"
	State.save_game()

func continue_game() -> void:
	if State.load_game():
		load_region(State.region_id,State.chef_position)
		chef.health.restore()
		State.controls_locked = false
		hud.mode = "none"
	else:
		new_game()

func travel(id: String) -> void:
	if State.controls_locked:
		return
	var from: String = State.region_id
	var spawn := Vector2(480,688)
	if id == "village":
		spawn = {"forest":Vector2(805,380),"mountains":Vector2(480,155),"volcano":Vector2(780,610),"kitchen":Vector2(480,640)}.get(from,Vector2(480,400))
	load_region(id,spawn)
	State.save_game()
	State.notified.emit("Arrived · " + hud.REGION_NAMES[id])

func load_region(id: String, spawn: Vector2) -> void:
	if is_instance_valid(region):
		$RegionSlot.remove_child(region)
		region.queue_free()
	for object: Node in get_tree().get_nodes_in_group("projectile"):
		object.queue_free()
	State.region_id = id
	region = load("res://scenes/regions/"+id+".tscn").instantiate()
	$RegionSlot.add_child(region)
	chef.position = spawn
	chef.checkpoint = spawn
	chef.height = 0
	chef.vertical_speed = 0
	chef.hovering = false
	chef.launch_wind = null
	chef.get_node("Camera2D").position = Vector2.ZERO
	chef.interaction.target = null
	chef.get_node("Camera2D").reset_smoothing()
	State.chef_position = spawn
	State.has_rock = false
	Sound.region(id)
	State.reveal(spawn)
	State.changed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		State.save_game()

func _exit_tree() -> void:
	Sound.stop_all()
