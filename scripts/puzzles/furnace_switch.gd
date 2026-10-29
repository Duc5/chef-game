extends FeastInteractable

# one of the three cold furnaces. you can't light them with the spatula,
# the only way is reflecting an ash imp's fireball into them. once all three
# are lit the greenhouse opens up

signal activated(id: String)


func _ready() -> void:
	super._ready()

	# joins damageable so reflected fireballs treat it like a target
	add_to_group("damageable")


## only a reflected fireball counts. normal spatula hits and imp shots
## that weren't reflected just do nothing, so the player has to work out the trick
func receive_hit(_direction: Vector2, reflected: bool) -> void:
	if not reflected or State.flags.get(stable_id, false):
		return

	State.set_flag(stable_id)
	Sound.effect("reflect")
	activated.emit(stable_id)

	# counts how many furnaces are lit so far
	var total: int = 0

	for id: String in ["furnace_0", "furnace_1", "furnace_2"]:

		if State.flags.get(id, false):
			total += 1

	if total == 3:
		State.set_flag("greenhouse_open")

	# saving after every furnace so you don't have to redo them if you quit halfway
	State.save_game()


func _draw() -> void:
	super._draw()

	# little flame on top once it's lit, so you can see which ones are left
	if State.flags.get(stable_id, false):
		draw_circle(Vector2(0, -15), 5, Color("fff1a8"))
		draw_circle(Vector2(0, -15), 2, Color("f49b44"))
