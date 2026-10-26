extends Node2D
## Same projectile and receiver interface for enemies and puzzle switches.
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
	if State.controls_locked:
		return
	lifetime -= delta
	previous_position = global_position
	global_position += direction*speed*delta
	if lifetime <= 0 or not Rect2(16,16,928,736).has_point(global_position):
		queue_free()
		return
	if reflected:
		for receiver: Node2D in get_tree().get_nodes_in_group("damageable"):
			if receiver.global_position.distance_to(global_position) < 17:
				receiver.receive_hit(direction,true)
				queue_free()
				return
	else:
		var player: Node2D = get_tree().get_first_node_in_group("player")
		if player != null and global_position.distance_to(player.global_position+Vector2(0,-5)) < 11:
			if player.attack_time > 0:
				reflect(player.aim)
			else:
				player.take_damage()
				queue_free()
	queue_redraw()

func reflect(new_direction: Vector2) -> void:
	if reflected:
		return
	reflected = true
	direction = new_direction.normalized()
	speed = 150.0
	Sound.effect("reflect")

func _draw() -> void:
	var tail: Color = Color("4cbfae") if reflected else Color("b7493b")
	var core: Color = Color("d2fff5") if reflected else Color("ffe4a1")
	draw_circle(-direction*5,6,Color(tail,0.35))
	draw_circle(Vector2.ZERO,4,tail)
	draw_circle(-direction,2,core)
