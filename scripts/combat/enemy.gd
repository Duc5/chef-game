extends Node2D

# shared script for both enemy types out in the regions around bramblewick.
# ash imps stay put and lob fireballs at the chef (which you can reflect
# back with the spatula), barklings chase you down and hit on contact

@export var enemy_id: String = "ash_imp"
@export var barkling: bool = false

var clock: float = 0.0
var shoot_timer: float = 1.8
var home: Vector2

@onready var health: HealthComponent = $Health


func _ready() -> void:
	add_to_group("damageable")
	home = position

	# saves a flag in State on death so the enemy stays dead when the chef
	# comes back through this region later in the run
	health.depleted.connect(func() -> void:
		State.set_flag(enemy_id)
		queue_free()
	)

	# already beaten this one earlier, so don't respawn it when the region reloads
	if State.flags.get(enemy_id, false):
		queue_free()


func _physics_process(delta: float) -> void:
	# freeze while dialogue, the journal or the map are open
	if State.controls_locked:
		return

	var chef: Node2D = get_tree().get_first_node_in_group("player")
	if chef == null:
		return

	# small bob up and down so they look alive even when they're standing still
	clock += delta
	$Sprite.position.y = -12 + sin(clock * 4) * 2

	var distance: float = global_position.distance_to(chef.global_position)

	if barkling:

		# barklings only chase inside 110px, so a careful player can sneak
		# round them instead of having to fight every single one
		if distance < 110 and distance > 10:
			position += (chef.global_position - position).normalized() * 26 * delta

		elif distance < 15:
			chef.take_damage()

	else:

		shoot_timer -= delta

		if shoot_timer <= 0 and distance < 330:
			shoot_timer = 2.4
			fire(chef.global_position)

		# imp glows yellow right before it throws, which gives the chef time
		# to line up a spatula reflect instead of just eating the hit
		$Sprite.modulate = Color("ffe1a1") if shoot_timer < 0.6 else Color.WHITE

	# _draw needs this every frame for the wind up ring
	queue_redraw()


func fire(target: Vector2) -> void:
	var projectile: Node2D = preload("res://scenes/objects/projectile.tscn").instantiate()

	# spawns slightly above the imp's feet so the fireball comes out of its hands
	projectile.position = global_position + Vector2(0, -6)
	projectile.direction = (target - projectile.position).normalized()

	get_parent().add_child(projectile)


## called when something hits the enemy, either a spatula swing or a
## fireball the chef reflected. knocks it back along direction if the
## hit actually counted (HealthComponent ignores hits during i-frames)
func receive_hit(direction: Vector2, _reflected: bool) -> void:
	if health.hurt():
		position += direction * 8
		Sound.effect("whack")


func _draw() -> void:
	# same timing as the yellow glow, the ring just makes the imp's wind up
	# easier to read when there's a lot going on
	if not barkling and shoot_timer < 0.6:
		draw_arc(Vector2(0, -10), 16, 0, TAU, 16, Color("f8bf63"), 1)
