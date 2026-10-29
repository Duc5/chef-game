extends Node2D

## draws the chef's costume (toque, coat, neckerchief) and the spatula over the
## ninja adventure character sprite. doing it in code instead of a new sprite
## sheet means it lines up with the pack's 32px animations without needing
## a matching set of hand drawn frames

var actor: CharacterBody2D


func _ready() -> void:
	actor = get_parent()


func _process(_delta: float) -> void:
	# redraws every frame because the costume has to follow the walk bob,
	# jumps and the spatula swing
	queue_redraw()


func _draw() -> void:
	if actor == null:
		return

	# lift is the jump height, bob is a one pixel step while walking.
	# rounding the bob keeps it pixel perfect instead of going blurry
	var lift: float = actor.height
	var bob: float = 0.0 if actor.velocity.length() < 5 else roundf(sin(actor.anim_clock * 15.0))
	var offset := Vector2(0, -lift + bob)

	# shadow stays on the ground (drawn before the offset) so you can
	# tell how high the chef is mid jump
	draw_circle(Vector2(0, 1), 6, Color(0.1, 0.16, 0.18, 0.3))

	draw_set_transform(offset)

	# face + eyes
	draw_rect(Rect2(-5, -19, 10, 10), Color("644c40"))
	draw_rect(Rect2(-4, -18, 8, 8), Color("dfb481"))
	draw_rect(Rect2(-3, -16, 2, 2), Color("333e49"))
	draw_rect(Rect2(2, -16, 2, 2), Color("333e49"))

	# the toque, dark outline first then the ivory layers on top
	draw_rect(Rect2(-7, -27, 14, 8), Color("29313c"))
	draw_rect(Rect2(-8, -25, 16, 6), Color("f5eedc"))
	draw_rect(Rect2(-6, -29, 12, 6), Color("f5eedc"))
	draw_rect(Rect2(-4, -30, 8, 2), Color("fff9e6"))
	draw_rect(Rect2(-6, -20, 12, 3), Color("c7d8d5"))

	# coat, sleeves, red neckerchief and the button strip
	draw_rect(Rect2(-5, -10, 10, 8), Color("eee8d4"))
	draw_rect(Rect2(-7, -9, 2, 6), Color("e9ddbe"))
	draw_rect(Rect2(5, -9, 2, 6), Color("e9ddbe"))
	draw_rect(Rect2(-5, -10, 10, 2), Color("af4b3a"))
	draw_rect(Rect2(-1, -8, 2, 5), Color("fff8df"))
	draw_rect(Rect2(2, -6, 1, 1), Color("424656"))

	# pale ring while dodging so the player can see their i-frames
	if actor.dodge_time > 0:
		draw_arc(Vector2.ZERO, 12, 0, TAU, 12, Color(0.85, 0.96, 1, 0.6), 1)

	var direction: Vector2 = actor.aim
	var angle: float = direction.angle()

	# sweeps the spatula across the aim direction during an attack, plus a
	# swoosh arc so the reflect window is easy to see
	if actor.attack_time > 0:
		angle += (0.13 - actor.attack_time) * 10.0 - 0.6
		draw_arc(Vector2(0, -8), 25, angle - 0.4, angle + 0.6, 12, Color("fff2bc"), 2)

	# rotates the drawing space so the spatula below always points where the chef aims
	draw_set_transform(offset + Vector2(0, -6), angle)

	# spatula handle
	draw_rect(Rect2(7, -1, 15, 3), Color("403d43"))
	draw_rect(Rect2(8, 0, 15, 1), Color("b57b48"))

	# spatula head with the two slots
	draw_rect(Rect2(20, -5, 10, 10), Color("283849"))
	draw_rect(Rect2(21, -4, 8, 8), Color("c6d8d5"))

	for x: int in [23, 26]:
		draw_rect(Rect2(x, -2, 1, 4), Color("5b7485"))

	draw_set_transform(Vector2.ZERO)

	# stone floats above the chef's head while carried, so you always
	# know whether you've got one ready to throw
	if State.has_rock:
		draw_circle(Vector2(0, -36 - lift), 4, Color("8b9d9c"))
