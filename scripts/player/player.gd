class_name ChefPlayer
extends CharacterBody2D

# the chef. handles walking, dodging, the spatula (attack + reflect),
# hopping between updrafts, throwing stones and pressing E on things.
# health and picking the interact target live in their own components

signal fell

const WindRules = preload("res://scripts/puzzles/wind_course.gd")

@export var speed: float = 92.0
@export var dodge_speed: float = 240.0

var aim: Vector2 = Vector2.RIGHT
var facing: Vector2 = Vector2.DOWN

# fake z axis. the game is top down, so "height" is just how far up we
# draw the chef, it doesn't move the collision at all
var height: float = 0.0
var vertical_speed: float = 0.0
var hovering: bool = false
var launch_wind: Node2D

var attack_time: float = 0.0
var attack_cooldown: float = 0.0
var dodge_time: float = 0.0
var dodge_direction: Vector2 = Vector2.DOWN

var anim_clock: float = 0.0
var footstep_clock: float = 0.0
var checkpoint: Vector2 = Vector2.ZERO
var hit_ids: Array[int] = []
var sheets: Dictionary = {}

@onready var health: HealthComponent = $Health
@onready var interaction: InteractionComponent = $Interaction
@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: Area2D = $AttackHitbox


func _ready() -> void:
	add_to_group("player")
	checkpoint = global_position

	# loads each animation sheet once up front so animate() can just swap textures
	for id: String in ["idle", "walk", "attack", "roll", "jump"]:
		sheets[id] = load("res://assets/game/" + id + ".png")

	health.depleted.connect(respawn)

	# every region is 960x768, so the camera stops at the edge of the map
	$Camera2D.limit_right = 960
	$Camera2D.limit_bottom = 768


func _physics_process(delta: float) -> void:
	# swallows input for a few frames after closing dialogue, otherwise the
	# E press that closed it would instantly start talking to them again
	if State.input_grace_frames > 0:
		State.input_grace_frames -= 1
		velocity = Vector2.ZERO
		return

	if State.controls_locked:
		velocity = Vector2.ZERO
		return

	anim_clock += delta

	# aim follows the mouse, falls back to facing if the cursor is right on top of the chef
	aim = (get_global_mouse_position() - global_position).normalized()
	if aim.length() < 0.1:
		aim = facing

	attack_time = maxf(0, attack_time - delta)
	attack_cooldown = maxf(0, attack_cooldown - delta)
	dodge_time = maxf(0, dodge_time - delta)

	var movement: Vector2 = Input.get_vector("left", "right", "up", "down")
	if movement.length() > 0:
		facing = movement.normalized()

	# dodge goes the way you're walking, or the way you're facing if standing still.
	# the short invulnerability is what lets you roll through an imp's fireball
	if Input.is_action_just_pressed("dodge") and dodge_time <= 0:
		dodge_time = 0.22
		dodge_direction = facing if movement == Vector2.ZERO else movement
		health.invulnerability = maxf(health.invulnerability, 0.3)

	var wind: Node2D = supporting_wind()

	# forgets the updraft we just launched from once we've left it or come
	# back down to hover height, so we can't instantly re-catch the same one
	if is_instance_valid(launch_wind) and (wind != launch_wind or (height <= WindRules.HOVER_HEIGHT and vertical_speed <= 0)):
		launch_wind = null

	hovering = wind != null and wind != launch_wind

	# normal jump from the ground, or a bigger hop when riding an updraft
	if Input.is_action_just_pressed("jump") and (height <= 0 or hovering):
		Sound.effect("jump")

		vertical_speed = WindRules.JUMP_SPEED if hovering else 115.0
		launch_wind = wind if hovering else null
		hovering = false
		height = maxf(height, 1)

	if hovering:
		# eases towards one fixed hover height instead of building up speed,
		# so every updraft behaves exactly the same (keeps the puzzles deterministic)
		height = move_toward(height, WindRules.HOVER_HEIGHT, 100 * delta)
		vertical_speed = 0

	elif height > 0:
		vertical_speed -= delta * 300
		height = maxf(0, height + vertical_speed * delta)

	# camera rises a bit with the chef so jumps don't leave them off the top of the screen
	$Camera2D.position.y = -height * 0.5

	velocity = dodge_direction * dodge_speed if dodge_time > 0 else movement * speed
	move_and_slide()

	footstep_clock -= delta

	if velocity.length() > 10 and height <= 0 and footstep_clock <= 0:
		Sound.effect("footstep")
		footstep_clock = 0.31

	# keeps the chef inside the region, the 56 at the top leaves room for the hud
	global_position = global_position.clamp(Vector2(24, 56), Vector2(936, 736))

	interaction.scan(self, facing)

	if Input.is_action_just_pressed("interact"):
		interaction.activate(self)

	if Input.is_action_just_pressed("attack"):
		attack()

	if Input.is_action_just_pressed("throw"):
		throw_rock()

	# moves the spatula hitbox out in front of wherever we're aiming
	hitbox.position = aim * 19.0 + Vector2(0, -5)

	if attack_time > 0:

		# hit_ids stops one swing hitting the same enemy every frame it overlaps
		for area: Area2D in hitbox.get_overlapping_areas():

			var receiver: Node = area.get_parent()

			if receiver.has_method("receive_hit") and receiver.get_instance_id() not in hit_ids:
				hit_ids.append(receiver.get_instance_id())
				receiver.receive_hit(aim, false)

		# reflects any fireball close by and roughly in front of the swing.
		# generous on purpose so reflecting feels reliable rather than pixel perfect
		for projectile: Node2D in get_tree().get_nodes_in_group("projectile"):

			if projectile.global_position.distance_to(global_position) < 36 and aim.dot((projectile.global_position - global_position).normalized()) > -0.3:
				projectile.reflect(aim)

	# State uses these for the map fog and for saving where the chef is
	State.chef_position = global_position
	State.reveal(global_position)

	animate()


## returns the updraft the chef is currently over, or null. only counts if
## we're already off the ground, so walking past an updraft doesn't lift you
func supporting_wind() -> Node2D:
	if height <= 0:
		return null

	for wind: Node2D in get_tree().get_nodes_in_group("updraft"):

		if global_position.distance_to(wind.global_position) < WindRules.RADIUS:
			return wind

	return null


## swings the spatula. can't attack mid dodge, and the cooldown stops
## you spamming click to keep the reflect window open forever
func attack() -> void:
	if attack_cooldown > 0 or dodge_time > 0:
		return

	attack_cooldown = 0.4
	attack_time = 0.18
	hit_ids.clear()

	Sound.effect("whack")


## throws the carried stone towards the mouse, if we have one
func throw_rock() -> void:
	if not State.has_rock:
		return

	State.has_rock = false

	var stone: Node2D = load("res://scenes/objects/rock_flight.tscn").instantiate()
	stone.position = global_position
	stone.direction = aim

	get_parent().add_child(stone)


func animate() -> void:
	# later checks win, so attacking overrides rolling, rolling overrides jumping etc
	var id: String = "idle"

	if velocity.length() > 1:
		id = "walk"

	if height > 0:
		id = "jump"

	if dodge_time > 0:
		id = "roll"

	if attack_time > 0:
		id = "attack"

	sprite.texture = sheets[id]

	# sheet rows are down, up, left, right
	var row: int = 0

	if absf(facing.x) > absf(facing.y):
		row = 2 if facing.x < 0 else 3

	elif facing.y < 0:
		row = 1

	var columns: int = int(sprite.texture.get_width() / 32)

	# idle plays slower than everything else so the chef isn't fidgeting when standing still
	var frame: int = int(anim_clock * (10.0 if id != "idle" else 3.0)) % columns

	sprite.region_rect = Rect2(frame * 32, row * 32, 32, 32)
	sprite.position.y = -12 - height

	$Costume.visible = true

	# flickers while invulnerable so it's obvious you can't be hit right now
	modulate.a = 0.5 if health.invulnerability > 0 and int(anim_clock * 14) % 2 == 0 else 1.0


## called by enemies and fireballs. a dodge completely avoids the hit
func take_damage() -> void:
	if dodge_time > 0:
		return

	if health.hurt():
		State.notified.emit("Ouch! That one singed the toque.")


## sends the chef back to the checkpoint when health runs out.
## resets all the jump / updraft state so we don't respawn mid air
func respawn() -> void:
	global_position = checkpoint

	height = 0
	vertical_speed = 0
	hovering = false
	launch_wind = null

	$Camera2D.position = Vector2.ZERO

	health.restore()

	State.chef_position = global_position
	fell.emit()

	State.notified.emit("Back at the last checkpoint. Your map and ingredients are safe.")
