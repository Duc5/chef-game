extends Node2D
const WindRules = preload("res://scripts/puzzles/wind_course.gd")
## Region-local hazards, checkpoints and presentation. Terrain lives in editable TileMapLayers.
@export var region_id: String = "village"
var clock: float = 0.0
var spout_clock: float = 1.0
var puzzle_hint_index: int = 0
var bridge_x: float = 480
const HINTS: Dictionary = {
	"forest":["The river is far too deep to cross on foot. Perhaps something nearby could help.","The large brittle tree beside the water might be long enough to reach the island.","Left click three times beside the weakened oak, aiming at its trunk. Cross the fallen tree to gather the mushroom."],
	"mountains":["The chasm seems empty, but the flags and wind chimes tell another story.","Throw loose stones into the gap. Some may rise, revealing hidden air currents.","E picks up a stone; right click throws it. Space jumps into a current, which holds you in the air. Jump again and steer sideways to reach the next current; keep going to the far plateau."],
	"volcano":["The dark furnace emblems appear to react to fire.","The imp and permanent spout launch fireballs. Your spatula can return them.","Aim at an emblem and left click just before a fireball reaches you. Reflected flames follow your cursor. Hit all three emblems to open the greenhouse."]}

func _ready() -> void:
	State.changed.connect(sync)
	if region_id == "forest":
		bridge_x = [416,480,544][State.seed_value % 3]
		$WeakenedOak.position.x = bridge_x
		$FallenBridge.position.x = bridge_x
		$Mushroom.position.x = bridge_x
		$RiverGap.position.x = bridge_x
		$RiverLeft.position.x = (bridge_x-18)/2
		$RiverLeft/Collision.shape = $RiverLeft/Collision.shape.duplicate()
		$RiverLeft/Collision.shape.size.x = bridge_x-18
		$RiverRight.position.x = (bridge_x+18+960)/2
		$RiverRight/Collision.shape = $RiverRight/Collision.shape.duplicate()
		$RiverRight/Collision.shape.size.x = 960-bridge_x-18
	if region_id == "mountains":
		for i: int in range(3):
			get_node("Wind%d"%i).position = WindRules.PATTERNS[State.seed_value%3][i]
	if region_id == "volcano":
		var patterns: Array = [[Vector2(384,304),Vector2(480,280),Vector2(576,304)],[Vector2(368,300),Vector2(480,320),Vector2(592,300)],[Vector2(384,328),Vector2(480,280),Vector2(576,328)]]
		for i: int in range(3):
			get_node("Switch%d"%i).position = patterns[State.seed_value%3][i]
	sync()

func sync() -> void:
	if region_id == "forest":
		var solved: bool = State.flags.get("forest_bridge",false)
		$RiverGap/Collision.set_deferred("disabled",solved)
		$FallenBridge.visible = solved
	if region_id == "volcano":
		var solved: bool = State.flags.get("greenhouse_open",false)
		$GreenhouseBarrier/Collision.set_deferred("disabled",solved)
		$ForgeDoor.visible = not solved
	if region_id == "kitchen" and State.flags.get("presented",false) and not has_node("IngredientDisplay"):
		var display := Node2D.new()
		display.name = "IngredientDisplay"
		display.z_index = 6
		add_child(display)
		for i: int in range(3):
			var icon := Sprite2D.new()
			icon.texture = load("res://assets/custom/"+State.ITEMS[i]+".svg")
			icon.position = Vector2(455+i*24,269)
			display.add_child(icon)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if State.controls_locked:
		return
	clock += delta
	var chef: ChefPlayer = get_tree().get_first_node_in_group("player")
	if chef == null:
		return
	if region_id == "village" and not State.flags.get("letter",false):
		$Letter.visible = clock > 3.0
		if clock > 3.0 and not State.flags.get("pigeon_landed",false):
			State.set_flag("pigeon_landed")
			State.notified.emit("A letter? For me?  Approach the envelope and press E.")
	if region_id == "forest" and chef.position.y > 422 and chef.position.y < 480:
		chef.checkpoint = Vector2(bridge_x,462)
	if region_id == "mountains":
		if chef.position.y > WindRules.CHASM_BOTTOM and chef.position.y < 530:
			chef.checkpoint = WindRules.CHECKPOINT
		if chef.position.y < WindRules.CHASM_BOTTOM and chef.position.y > WindRules.CHASM_TOP and chef.height <= 0:
			chef.respawn()
	if region_id == "volcano":
		if chef.position.y > 420 and chef.position.y < 470:
			chef.checkpoint = Vector2(480,452)
		spout_clock -= delta
		if spout_clock <= 0:
			spout_clock = 2.7
			var projectile: Node2D = preload("res://scenes/objects/projectile.tscn").instantiate()
			projectile.position = $Spout.position + Vector2(0,-6)
			projectile.direction = (chef.position-projectile.position).normalized()
			add_child(projectile)
	if Input.is_action_just_pressed("hint") and HINTS.has(region_id):
		if chef.position.y < 520 and chef.position.y > 200:
			State.dialogue_requested.emit("Optional hint %d / 3" % (mini(puzzle_hint_index,2)+1),[HINTS[region_id][mini(puzzle_hint_index,2)]])
			puzzle_hint_index += 1
		else:
			State.notified.emit("Hints are available near the region's main puzzle.")
	queue_redraw()

func _draw() -> void:
	if region_id == "forest":
		# Moving ripples retain the 16px pixel grid beneath the fallen log.
		for i: int in range(30):
			var x: float = fmod(i*37+clock*11,944)+8
			var y: float = 318+float((i*29)%80)
			draw_line(Vector2(x,y),Vector2(x+6,y),Color(0.64,0.88,0.86,0.35))
	if region_id == "mountains":
		for i: int in range(65):
			var p := Vector2(fmod(i*73+clock*18,960),fmod(i*37+clock*11,768))
			draw_rect(Rect2(p,Vector2(1,1)),Color(0.95,1,1,0.5))
		# Subtle clues without exposing the entire solution: wind chimes on the ledge.
		for i: int in range(3):
			var x: float = 530+i*7
			draw_line(Vector2(x,474),Vector2(x+sin(clock*3+i)*3,488),Color("d8d3ad"))
	if region_id == "volcano":
		for i: int in range(25):
			var p := Vector2(fmod(i*91+clock*4,960),768-fmod(i*41+clock*18,768))
			draw_rect(Rect2(p,Vector2(1,2)),Color(1,0.65,0.25,0.5))
		if spout_clock < 0.65:
			draw_arc($Spout.position-Vector2(0,12),21,0,TAU,20,Color("edab59"),1)
	if region_id == "village" and clock < 4.0:
		var t: float = minf(clock/3.0,1)
		var p: Vector2 = Vector2(280+cos(t*TAU*2)*70*(1-t),500+sin(t*TAU*2)*35-110*(1-t))
		draw_rect(Rect2(p+Vector2(-4,-3),Vector2(8,5)),Color("deded3"))
		draw_rect(Rect2(p+Vector2(3,-4),Vector2(4,4)),Color("9bb3bd"))
		draw_line(p,p+Vector2(-8,sin(clock*30)*6-3),Color("e5eee6"),3)
