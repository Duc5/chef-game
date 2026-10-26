extends FeastInteractable
signal activated(id: String)

func _ready() -> void:
	super._ready()
	add_to_group("damageable")

func receive_hit(_direction: Vector2, reflected: bool) -> void:
	if not reflected or State.flags.get(stable_id,false):
		return
	State.set_flag(stable_id)
	Sound.effect("reflect")
	activated.emit(stable_id)
	var total: int = 0
	for id: String in ["furnace_0","furnace_1","furnace_2"]:
		if State.flags.get(id,false): total += 1
	if total == 3:
		State.set_flag("greenhouse_open")
	State.save_game()

func _draw() -> void:
	super._draw()
	if State.flags.get(stable_id,false):
		draw_circle(Vector2(0,-15),5,Color("fff1a8"))
		draw_circle(Vector2(0,-15),2,Color("f49b44"))
