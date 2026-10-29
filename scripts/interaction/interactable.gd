class_name FeastInteractable
extends Node2D

# one script for everything the chef can press E on: villagers, gates between
# regions, the three ingredients, stones, the invitation letter and the
# kitchen counter. kind decides what happens, so level designers just drop
# one in and set the exports instead of writing a new script each time

@export var kind: String = "inspect"
@export var stable_id: String = ""
@export var display_name: String = "Inspect"
@export var description: String = "Looks like it's been here longer than the castle."
@export var destination: String = ""
@export var requires_flag: String = ""
@export var extra_reach: float = 0.0

var selected: bool = false


func _ready() -> void:
	add_to_group("interactable")

	# gives the sprite its own outline material so highlighting one thing
	# doesn't light up every other interactable using the same texture
	if has_node("Sprite"):
		var mat := ShaderMaterial.new()
		mat.shader = preload("res://scripts/interaction/outline.gdshader")
		$Sprite.material = mat

	# re-check visibility whenever State changes, e.g. hiding an ingredient
	# the moment it goes into the chef's bag
	State.changed.connect(sync)
	sync()


## hides ingredients and the letter once they've been collected / read,
## so they don't reappear when the chef walks back into a region
func sync() -> void:
	if kind == "ingredient":
		visible = stable_id not in State.inventory

	if kind == "letter":
		visible = not State.flags.get("letter", false)

	queue_redraw()


## whether the player's interaction check should consider this at all
func eligible() -> bool:
	return visible


## text for the prompt in the bottom bar when the chef is in range
func prompt() -> String:
	if kind == "npc":
		return "E  Talk · " + display_name

	if kind == "gate":
		return "E  Travel · " + display_name

	if kind == "ingredient":
		return "E  Gather · " + display_name

	if kind == "rock":
		return "E  Pick up a stone"

	if kind == "counter":
		return "E  Present ingredients"

	return "E  " + display_name


## turns the outline on or off. the player calls this on whatever's nearest
func highlight(value: bool) -> void:
	selected = value

	if has_node("Sprite") and $Sprite.material is ShaderMaterial:
		$Sprite.material.set_shader_parameter("selected", value)

	queue_redraw()


## runs when the chef presses E on this
func interact(_actor: Node2D) -> void:
	match kind:

		"npc":

			# each of these three villagers sends you after one ingredient,
			# so once you've got theirs they say something different
			var item: String = {
				"bram": "mushroom",
				"mira": "egg",
				"flint": "pepper",
			}.get(stable_id, "")

			if item in State.inventory:

				var after: String = {
					"bram": "Bram: That's the Dewcrown! Keep it somewhere dry. And if the forestry guild asks about that tree, you never saw me.",
					"mira": "Mira: A Skyfeather Egg, and not a single crack in it. So the wind really did carry you over the chasm? I've never been brave enough to try.",
					"flint": "Flint: IS THAT THE CINDERHEART PEPPER?! Careful, don't squeeze it. Tell the King I've got ideas for a new royal weapon.",
				}[stable_id]

				State.dialogue_requested.emit(display_name, [after])

			# rowan and quill get special lines once the chef has everything,
			# nudging them back towards the castle kitchen
			elif stable_id == "rowan" and State.all_collected():
				State.dialogue_requested.emit(display_name, ["All three? I haven't seen a haul like that since the Great Turnip Expedition. Don't ask about the turnips. Go on, the kitchen's waiting!"])

			elif stable_id == "quill" and State.all_collected():
				State.dialogue_requested.emit(display_name, ["By the King's golden cutlery, you actually did it! Put all three on the preparation counter."])

			else:
				State.talk(stable_id, display_name)

		"letter":

			# reading the royal invitation is what kicks the quest off,
			# so we save straight away
			State.set_flag("letter")
			State.talk("letter", "The Royal Invitation")
			State.save_game()

		"gate":
			State.travel_requested.emit(destination)

		"ingredient":

			# some ingredients are locked behind a puzzle flag. until it's
			# solved, the chef just gets the description as a clue instead
			if requires_flag != "" and not State.flags.get(requires_flag, false):
				State.dialogue_requested.emit(display_name, [description])

			else:
				State.collect(stable_id)

		"rock":
			State.has_rock = true

		"counter":

			if State.all_collected():
				State.ending_requested.emit()

			else:
				State.dialogue_requested.emit("The Royal Kitchen", ["The counter's still missing something. Check your letter to see which ingredients you need."])

		_:
			State.dialogue_requested.emit(display_name, [description])


func _draw() -> void:
	if selected:
		draw_arc(Vector2(0, 0), 10, 0, TAU, 16, Color(1, 1, 1, 0.8), 1)

	# four little sparkles orbiting ingredients so they stand out from the scenery
	if kind == "ingredient":
		var t: float = float(Time.get_ticks_msec()) / 700.0

		for i: int in range(4):

			# 1.57 is roughly a quarter turn, so the four sparkles are spaced evenly
			var p := Vector2(cos(t + i * 1.57) * 12, sin(t + i * 1.57) * 6 - 12)

			draw_rect(Rect2(p, Vector2(1, 2)), Color("fff3bc"))
