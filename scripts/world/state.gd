extends Node
const WindRules = preload("res://scripts/puzzles/wind_course.gd")
## Persistent domain state. UI observes changed; regions use stable flag IDs.
signal changed
signal notified(message: String)
signal dialogue_requested(title: String, lines: Array)
signal travel_requested(region_id: String)
signal ending_requested

const SAVE_PATH: String = "user://royal_feast.json"
const ITEMS: Array[String] = ["mushroom", "egg", "pepper"]
var inventory: Array[String] = []
var flags: Dictionary = {}
var discovered: Dictionary = {}
var conversations: Dictionary = {}
var seed_value: int = 0
var region_id: String = "village"
var chef_position: Vector2 = Vector2(280, 500)
var controls_locked: bool = true
var input_grace_frames: int = 0
var has_rock: bool = false
var save_enabled: bool = true
var story: Dictionary = {}

func _ready() -> void:
	story = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogues/story.json"))
	setup_input()

func setup_input() -> void:
	var actions: Dictionary = {"left": KEY_A, "right": KEY_D, "up": KEY_W, "down": KEY_S, "interact": KEY_E, "dodge": KEY_SHIFT, "jump": KEY_SPACE, "hint": KEY_H, "journal": KEY_J, "map": KEY_M, "pause": KEY_ESCAPE}
	for action: String in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.physical_keycode = actions[action]
			InputMap.action_add_event(action, event)
	for action: String in ["attack", "throw"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT if action == "attack" else MOUSE_BUTTON_RIGHT
			InputMap.action_add_event(action, event)

func reset() -> void:
	inventory.clear()
	flags.clear()
	discovered.clear()
	conversations.clear()
	seed_value = int(Time.get_unix_time_from_system()) % 100000
	region_id = "village"
	chef_position = Vector2(280, 500)
	has_rock = false
	changed.emit()

func set_flag(id: String, value: Variant = true) -> void:
	flags[id] = value
	changed.emit()

func collect(id: String) -> bool:
	if id not in ITEMS or id in inventory:
		return false
	inventory.append(id)
	changed.emit()
	Sound.effect("collect")
	notified.emit("Obtained — " + {"mushroom":"Dewcrown Mushroom", "egg":"Skyfeather Egg", "pepper":"Cinderheart Pepper"}[id])
	save_game()
	return true

func all_collected() -> bool:
	return inventory.size() == ITEMS.size()

func talk(key: String, title: String) -> void:
	var use_key: String = key
	if conversations.has(key) and story.has(key + "_repeat"):
		use_key += "_repeat"
	conversations[key] = true
	var lines: Array = story.get(use_key, ["The countryside has many stories to tell."])
	if lines.is_empty():
		lines = ["Safe travels, chef. Your royal letter will remind you what remains."]
	dialogue_requested.emit(title, lines)
	Sound.effect("talk")

func reveal(pos: Vector2) -> void:
	if not discovered.has(region_id):
		discovered[region_id] = {}
	var cell := Vector2i(pos / 16.0)
	for y: int in range(-6, 7):
		for x: int in range(-6, 7):
			if x*x+y*y <= 36:
				var c: Vector2i = cell + Vector2i(x,y)
				if c.x >= 0 and c.y >= 0 and c.x < 60 and c.y < 48:
					discovered[region_id][str(c.x)+","+str(c.y)] = true

func save_game(path: String = SAVE_PATH) -> bool:
	if not save_enabled:
		return true
	var safe_position: Vector2 = chef_position
	# A save taken in mid-flight must never reload into an endless falling loop.
	if region_id == "mountains" and safe_position.y > WindRules.CHASM_TOP and safe_position.y < WindRules.CHASM_BOTTOM:
		safe_position = WindRules.CHECKPOINT
	var data: Dictionary = {"version":1, "inventory":inventory, "flags":flags, "discovered":discovered, "conversations":conversations, "seed":seed_value, "region":region_id, "position":[safe_position.x,safe_position.y]}
	var file := FileAccess.open(path+".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return DirAccess.rename_absolute(path+".tmp",path) == OK

func load_game(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary or data.get("version",0) != 1:
		return false
	inventory.clear()
	for id: Variant in data.get("inventory",[]):
		if str(id) in ITEMS and str(id) not in inventory:
			inventory.append(str(id))
	flags = data.get("flags",{})
	discovered = data.get("discovered",{})
	conversations = data.get("conversations",{})
	seed_value = int(data.get("seed",0))
	region_id = str(data.get("region","village"))
	if region_id not in ["village","forest","mountains","volcano","kitchen"]:
		region_id = "village"
	var pos: Array = data.get("position",[280,500])
	chef_position = Vector2(float(pos[0]), float(pos[1]))
	if region_id == "mountains" and chef_position.y > WindRules.CHASM_TOP and chef_position.y < WindRules.CHASM_BOTTOM:
		chef_position = WindRules.CHECKPOINT
	has_rock = false
	changed.emit()
	return true
