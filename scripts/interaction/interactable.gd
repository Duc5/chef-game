class_name FeastInteractable
extends Node2D
@export var kind: String = "inspect"
@export var stable_id: String = ""
@export var display_name: String = "Inspect"
@export var description: String = "An old piece of the kingdom."
@export var destination: String = ""
@export var requires_flag: String = ""
@export var extra_reach: float = 0.0
var selected: bool = false

func _ready() -> void:
	add_to_group("interactable")
	if has_node("Sprite"):
		var mat := ShaderMaterial.new()
		mat.shader = preload("res://scripts/interaction/outline.gdshader")
		$Sprite.material = mat
	State.changed.connect(sync)
	sync()

func sync() -> void:
	if kind == "ingredient":
		visible = stable_id not in State.inventory
	if kind == "letter":
		visible = not State.flags.get("letter",false)
	queue_redraw()

func eligible() -> bool:
	return visible

func prompt() -> String:
	if kind == "npc": return "E  Talk · " + display_name
	if kind == "gate": return "E  Travel · " + display_name
	if kind == "ingredient": return "E  Gather · " + display_name
	if kind == "rock": return "E  Pick up a stone"
	if kind == "counter": return "E  Present ingredients"
	return "E  " + display_name

func highlight(value: bool) -> void:
	selected = value
	if has_node("Sprite") and $Sprite.material is ShaderMaterial:
		$Sprite.material.set_shader_parameter("selected",value)
	queue_redraw()

func interact(_actor: Node2D) -> void:
	match kind:
		"npc":
			var item: String = {"bram":"mushroom","mira":"egg","flint":"pepper"}.get(stable_id,"")
			if item in State.inventory:
				var after: String = {"bram":"Bram: You found the Dewcrown! Keep it safe. And, er, maybe don't tell the forestry guild about that tree.","mira":"Mira: A Skyfeather Egg? Incredible! Tell me, did the wind really carry you over the chasm?","flint":"Flint: THE CINDERHEART PEPPER! YOU ACTUALLY FOUND IT! Tell the King I've got some ideas for a new royal weapon."}[stable_id]
				State.dialogue_requested.emit(display_name,[after])
			elif stable_id == "rowan" and State.all_collected():
				State.dialogue_requested.emit(display_name,["All three? Remarkable! I haven't seen such a journey since the Great Turnip Expedition. Don't ask about the turnips. Go! The Royal Kitchen awaits!"])
			elif stable_id == "quill" and State.all_collected():
				State.dialogue_requested.emit(display_name,["By the King's golden cutlery, you've actually done it! Place the three ingredients on the preparation counter."])
			else:
				State.talk(stable_id,display_name)
		"letter":
			State.set_flag("letter")
			State.talk("letter","The Royal Invitation")
			State.save_game()
		"gate":
			State.travel_requested.emit(destination)
		"ingredient":
			if requires_flag != "" and not State.flags.get(requires_flag,false):
				State.dialogue_requested.emit(display_name,[description])
			else:
				State.collect(stable_id)
		"rock":
			State.has_rock = true
		"counter":
			if State.all_collected():
				State.ending_requested.emit()
			else:
				State.dialogue_requested.emit("The Royal Kitchen",["The preparation counter awaits three legendary ingredients. Your letter lists what remains."])
		_:
			State.dialogue_requested.emit(display_name,[description])

func _draw() -> void:
	if selected:
		draw_arc(Vector2(0,0),10,0,TAU,16,Color(1,1,1,0.8),1)
	if kind == "ingredient":
		var t: float = float(Time.get_ticks_msec())/700.0
		for i: int in range(4):
			var p := Vector2(cos(t+i*1.57)*12,sin(t+i*1.57)*6-12)
			draw_rect(Rect2(p,Vector2(1,2)),Color("fff3bc"))
