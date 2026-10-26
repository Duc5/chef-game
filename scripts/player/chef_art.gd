extends Node2D
## Pixel costume overlay on the pack's 32px animated character. No mismatched raster assets.
var actor: CharacterBody2D

func _ready() -> void:
	actor = get_parent()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if actor == null:
		return
	var lift: float = actor.height
	var bob: float = 0.0 if actor.velocity.length() < 5 else roundf(sin(actor.anim_clock*15.0))
	var offset := Vector2(0, -lift+bob)
	draw_circle(Vector2(0,1),6,Color(0.1,0.16,0.18,0.3))
	draw_set_transform(offset)
	# Dark outlining, ivory toque, warm white coat and red neckerchief.
	draw_rect(Rect2(-5,-19,10,10),Color("644c40"))
	draw_rect(Rect2(-4,-18,8,8),Color("dfb481"))
	draw_rect(Rect2(-3,-16,2,2),Color("333e49"))
	draw_rect(Rect2(2,-16,2,2),Color("333e49"))
	draw_rect(Rect2(-7,-27,14,8),Color("29313c"))
	draw_rect(Rect2(-8,-25,16,6),Color("f5eedc"))
	draw_rect(Rect2(-6,-29,12,6),Color("f5eedc"))
	draw_rect(Rect2(-4,-30,8,2),Color("fff9e6"))
	draw_rect(Rect2(-6,-20,12,3),Color("c7d8d5"))
	draw_rect(Rect2(-5,-10,10,8),Color("eee8d4"))
	draw_rect(Rect2(-7,-9,2,6),Color("e9ddbe"))
	draw_rect(Rect2(5,-9,2,6),Color("e9ddbe"))
	draw_rect(Rect2(-5,-10,10,2),Color("af4b3a"))
	draw_rect(Rect2(-1,-8,2,5),Color("fff8df"))
	draw_rect(Rect2(2,-6,1,1),Color("424656"))
	if actor.dodge_time > 0:
		draw_arc(Vector2.ZERO,12,0,TAU,12,Color(0.85,0.96,1,0.6),1)
	var direction: Vector2 = actor.aim
	var angle: float = direction.angle()
	if actor.attack_time > 0:
		angle += (0.13-actor.attack_time)*10.0-0.6
		draw_arc(Vector2(0,-8),25,angle-0.4,angle+0.6,12,Color("fff2bc"),2)
	draw_set_transform(offset+Vector2(0,-6),angle)
	draw_rect(Rect2(7,-1,15,3),Color("403d43"))
	draw_rect(Rect2(8,0,15,1),Color("b57b48"))
	draw_rect(Rect2(20,-5,10,10),Color("283849"))
	draw_rect(Rect2(21,-4,8,8),Color("c6d8d5"))
	for x: int in [23,26]:
		draw_rect(Rect2(x,-2,1,4),Color("5b7485"))
	draw_set_transform(Vector2.ZERO)
	if State.has_rock:
		draw_circle(Vector2(0,-36-lift),4,Color("8b9d9c"))
