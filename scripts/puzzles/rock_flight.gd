extends Node2D
const WindRules = preload("res://scripts/puzzles/wind_course.gd")
var direction: Vector2 = Vector2.UP
var age: float = 0.0
var caught: bool = false
var caught_age: float = 0.0

func _physics_process(delta: float) -> void:
	if State.controls_locked:
		return
	age += delta
	if not caught:
		position += direction*155*delta
	else:
		caught_age += delta
	for wind: Node2D in get_tree().get_nodes_in_group("updraft"):
		if global_position.distance_to(wind.global_position) < WindRules.RADIUS:
			caught = true
			wind.reveal()
	if (caught and caught_age > 1.7) or (not caught and age > 2.3):
		queue_free()
	queue_redraw()

func _draw() -> void:
	var lift: float = minf(caught_age*45,28) if caught else sin(minf(age/2.3,1)*PI)*18
	draw_ellipse_shadow()
	draw_rect(Rect2(-3,-lift-3,6,5),Color("596877"))
	draw_rect(Rect2(-2,-lift-3,3,2),Color("c8d9dd"))

func draw_ellipse_shadow() -> void:
	draw_circle(Vector2.ZERO,3,Color(0,0,0,0.25))
