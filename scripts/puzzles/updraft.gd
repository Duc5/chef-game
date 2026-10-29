extends Node2D

# a hidden updraft over the chasm. invisible until a thrown stone gets caught
# in it (or the chef is riding it), then it shows swirling wind for a few
# seconds so you can see where to jump. the actual lifting is in ChefPlayer

const WindRules = preload("res://scripts/puzzles/wind_course.gd")

var reveal_time: float = 0.0
var clock: float = 0.0


func _ready() -> void:
	add_to_group("updraft")


## called by a stone that's been caught in this updraft. shows the wind for 6s
## and flags that the player has worked out the stone trick
func reveal() -> void:
	reveal_time = 6.0
	State.set_flag("wind_discovered")


func _physics_process(delta: float) -> void:
	if State.controls_locked:
		return

	clock += delta
	reveal_time = maxf(0, reveal_time - delta)

	# always visible while the chef is actually floating in it, otherwise
	# you'd be hovering over what looks like thin air
	var chef: Node2D = get_tree().get_first_node_in_group("player")

	if chef != null and chef.height > 0 and chef.global_position.distance_to(global_position) < WindRules.RADIUS:
		reveal_time = maxf(reveal_time, 0.5)

	queue_redraw()


func _draw() -> void:
	if reveal_time > 0:

		# seven little gusts spinning round and drifting upwards, then looping
		# back to the bottom (that's what the fmod is for)
		for i: int in range(7):

			var a: float = clock * 2 + i * TAU / 7
			var p := Vector2(cos(a) * 21, sin(a) * 9 - 10 - fmod(clock * 15 + i * 5, 30))

			draw_arc(p, 6, a, a + 1.8, 5, Color(0.75, 0.95, 1.0, 0.75), 1)
