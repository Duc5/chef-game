extends Node2D
const WindRules = preload("res://scripts/puzzles/wind_course.gd")
var reveal_time: float = 0.0
var clock: float = 0.0

func _ready() -> void:
	add_to_group("updraft")

func reveal() -> void:
	reveal_time = 6.0
	State.set_flag("wind_discovered")

func _physics_process(delta: float) -> void:
	if State.controls_locked:
		return
	clock += delta
	reveal_time = maxf(0,reveal_time-delta)
	var chef: Node2D = get_tree().get_first_node_in_group("player")
	if chef != null and chef.height > 0 and chef.global_position.distance_to(global_position) < WindRules.RADIUS:
		reveal_time = maxf(reveal_time,0.5)
	queue_redraw()

func _draw() -> void:
	if reveal_time > 0:
		for i: int in range(7):
			var a: float = clock*2+i*TAU/7
			var p := Vector2(cos(a)*21,sin(a)*9-10-fmod(clock*15+i*5,30))
			draw_arc(p,6,a,a+1.8,5,Color(0.75,0.95,1.0,0.75),1)
