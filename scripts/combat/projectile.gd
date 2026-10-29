extends Node2D

## ash imp fireball. starts out heading for the chef, but a spatula swing at
## the right moment reflects it, and then it can hit anything in "damageable",
## which means enemies AND puzzle switches. same interface for both, so a
## switch just needs a receive_hit() to be solvable with a reflected shot

@export var direction: Vector2 = Vector2.DOWN
@export var speed: float = 64.0

var reflected: bool = false
var lifetime: float = 7.0
var previous_position: Vector2


func _ready() -> void:
	Sound.effect("fireball")
	add_to_group("projectile")
	previous_position = global_position


func _physics_process(delta: float) -> void:
	# fireballs hang in the air while dialogue / journal / map are open
	if State.controls_locked:
		return

	lifetime -= delta

	previous_position = global_position
	global_position += direction * speed * delta

	# clean up once it times out or leaves the region, so stray
	# fireballs don't pile up off screen
	if lifetime <= 0 or not Rect2(16, 16, 928, 736).has_point(global_position):
		queue_free()
		return

	if reflected:

		# once it's been reflected it's the chef's shot, so check every enemy
		# and puzzle switch and hit the first one it's close enough to
		for receiver: Node2D in get_tree().get_nodes_in_group("damageable"):

			if receiver.global_position.distance_to(global_position) < 17:
				receiver.receive_hit(direction, true)
				queue_free()
				return

	else:

		var player: Node2D = get_tree().get_first_node_in_group("player")

		# the -5 lines the check up with the chef's body instead of their feet
		if player != null and global_position.distance_to(player.global_position + Vector2(0, -5)) < 11:

			# mid swing means a successful reflect, sends it back wherever the
			# chef is aiming. otherwise it's a normal hit
			if player.attack_time > 0:
				reflect(player.aim)

			else:
				player.take_damage()
				queue_free()

	queue_redraw()


## flips the fireball onto the chef's side and fires it off along new_direction.
## a lot faster after the reflect so it actually feels like a return shot
func reflect(new_direction: Vector2) -> void:
	# guard so the same swing can't reflect it twice
	if reflected:
		return

	reflected = true
	direction = new_direction.normalized()
	speed = 150.0

	Sound.effect("reflect")


func _draw() -> void:
	# red/orange while it's the imp's fireball, teal once it's reflected, so you
	# can always tell at a glance whether it's going to hurt you or not
	var tail: Color = Color("4cbfae") if reflected else Color("b7493b")
	var core: Color = Color("d2fff5") if reflected else Color("ffe4a1")

	draw_circle(-direction * 5, 6, Color(tail, 0.35))
	draw_circle(Vector2.ZERO, 4, tail)
	draw_circle(-direction, 2, core)
