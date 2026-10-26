extends Node2D
@export var enemy_id: String = "ash_imp"
@export var barkling: bool = false
var clock: float = 0.0
var shoot_timer: float = 1.8
var home: Vector2
@onready var health: HealthComponent = $Health

func _ready() -> void:
	add_to_group("damageable")
	home = position
	health.depleted.connect(func() -> void:
		State.set_flag(enemy_id)
		queue_free())
	if State.flags.get(enemy_id,false):
		queue_free()

func _physics_process(delta: float) -> void:
	if State.controls_locked:
		return
	var chef: Node2D = get_tree().get_first_node_in_group("player")
	if chef == null:
		return
	clock += delta
	$Sprite.position.y = -12+sin(clock*4)*2
	var distance: float = global_position.distance_to(chef.global_position)
	if barkling:
		if distance < 110 and distance > 10:
			position += (chef.global_position-position).normalized()*26*delta
		elif distance < 15:
			chef.take_damage()
	else:
		shoot_timer -= delta
		if shoot_timer <= 0 and distance < 330:
			shoot_timer = 2.4
			fire(chef.global_position)
		$Sprite.modulate = Color("ffe1a1") if shoot_timer < 0.6 else Color.WHITE
	queue_redraw()

func fire(target: Vector2) -> void:
	var projectile: Node2D = preload("res://scenes/objects/projectile.tscn").instantiate()
	projectile.position = global_position+Vector2(0,-6)
	projectile.direction = (target-projectile.position).normalized()
	get_parent().add_child(projectile)

func receive_hit(direction: Vector2, _reflected: bool) -> void:
	if health.hurt():
		position += direction*8
		Sound.effect("whack")

func _draw() -> void:
	if not barkling and shoot_timer < 0.6:
		draw_arc(Vector2(0,-10),16,0,TAU,16,Color("f8bf63"),1)
