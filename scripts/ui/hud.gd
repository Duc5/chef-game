extends Control
## Presentation only: state snapshots, menus, paced dialogue and discovery maps.
signal new_game_requested
signal continue_requested
const REGION_NAMES: Dictionary = {"village":"Bramblewick Village","forest":"Riverwood Forest","mountains":"Whispering Peaks","volcano":"Emberfall Forge","kitchen":"The Royal Kitchen"}
var font: Font = preload("res://assets/game/font.ttf")
var mode: String = "title"
var dialogue_title: String = ""
var lines: Array = []
var line_index: int = 0
var toast: String = ""
var toast_timer: float = 0
var buttons: Dictionary = {}
var ending_after_dialogue: bool = false
var ending_clock: float = 0
var autosave_clock: float = 0
var quests: Array[IngredientData] = []

func _ready() -> void:
	var spaced_font := FontVariation.new()
	spaced_font.base_font = font
	spaced_font.spacing_space = 2
	font = spaced_font
	State.dialogue_requested.connect(open_dialogue)
	State.notified.connect(func(message: String) -> void:
		toast = message
		toast_timer = 5.5)
	for id: String in State.ITEMS:
		quests.append(load("res://data/quests/"+id+".tres"))
	mouse_default_cursor_shape = Control.CURSOR_ARROW

func chef() -> ChefPlayer:
	return get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	toast_timer = maxf(0,toast_timer-delta)
	if mode == "ending": ending_clock += delta
	if mode == "none":
		autosave_clock += delta
		if autosave_clock >= 12:
			autosave_clock = 0
			State.save_game()
	queue_redraw()

func set_mode(value: String) -> void:
	if mode != "none" and value == "none":
		State.input_grace_frames = 2
	mode = value
	State.controls_locked = value != "none"

func open_dialogue(title: String, content: Array) -> void:
	dialogue_title = title
	lines = content.duplicate()
	line_index = 0
	set_mode("dialogue")

func begin_ending() -> void:
	State.set_flag("presented")
	ending_after_dialogue = true
	open_dialogue("A Feast Fit for a King",State.story["ending"])

func advance() -> void:
	line_index += 1
	if line_index >= lines.size():
		if ending_after_dialogue:
			ending_after_dialogue = false
			State.set_flag("completed")
			State.save_game()
			ending_clock = 0
			set_mode("ending")
		else:
			set_mode("none")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for action: String in buttons:
			if buttons[action].has_point(get_global_mouse_position()):
				perform(action)
				get_viewport().set_input_as_handled()
				return
		if mode == "dialogue":
			advance()
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("pause"):
		if mode == "none": set_mode("pause")
		elif mode in ["pause","journal","map"]: set_mode("none")
		elif mode == "dialogue": advance()
		get_viewport().set_input_as_handled()
	elif mode == "dialogue" and (event.is_action_pressed("interact") or event.is_action_pressed("jump") or event.is_action_pressed("ui_accept")):
		advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("journal") and mode in ["none","journal"]:
		if State.flags.get("letter",false):
			set_mode("none" if mode == "journal" else "journal")
		else:
			State.notified.emit("Open the pigeon-delivered letter with E first.")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("map") and mode in ["none","map"]:
		set_mode("none" if mode == "map" else "map")
		get_viewport().set_input_as_handled()
	elif mode == "title" and event.is_action_pressed("ui_accept"):
		perform("new")
	elif mode == "ending" and ending_clock > 2 and event.is_action_pressed("ui_accept"):
		set_mode("title")

func perform(action: String) -> void:
	match action:
		"new": new_game_requested.emit()
		"continue": continue_requested.emit()
		"resume": set_mode("none")
		"save":
			State.notified.emit("Journey saved." if State.save_game() else "Could not save the journey.")
		"sound": Sound.toggle()
		"title": State.save_game(); set_mode("title")
		"quit": State.save_game(); get_tree().quit()
		"close": set_mode("none")
		"letter": open_dialogue("The Royal Invitation",State.story["letter"])

func text_at(value: String, pos: Vector2, size: int = 8, color: Color = Color("f4e9ca")) -> void:
	draw_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func center(value: String, y: float, size: int = 8, color: Color = Color("f4e9ca")) -> void:
	var w: float = font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	text_at(value,Vector2((640-w)/2,y),size,color)

func paragraph(value: String, pos: Vector2, width: float, size: int = 9, color: Color = Color("423c40"), line_height: int = 14) -> float:
	var current: String = ""
	var y: float = pos.y
	for word: String in value.split(" "):
		var proposed: String = current+" "+word if current != "" else word
		if font.get_string_size(proposed,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x > width and current != "":
			text_at(current,Vector2(pos.x,y),size,color)
			y += line_height
			current = word
		else:
			current = proposed
	text_at(current,Vector2(pos.x,y),size,color)
	return y+line_height

func panel(rect: Rect2, parchment: bool = false) -> void:
	draw_rect(Rect2(rect.position+Vector2(3,4),rect.size),Color(0.02,0.04,0.08,0.5))
	draw_rect(rect,Color("e8d5a7") if parchment else Color("1d2e38"))
	draw_rect(rect,Color("9b784a") if parchment else Color("b5945f"),false,1)
	draw_rect(Rect2(rect.position+Vector2(3,3),rect.size-Vector2(6,6)),Color("b9a078") if parchment else Color("465452"),false,1)
	for p: Vector2 in [rect.position+Vector2(6,6),rect.position+Vector2(rect.size.x-7,6),rect.end-Vector2(7,7),rect.position+Vector2(6,rect.size.y-7)]:
		draw_rect(Rect2(p,Vector2(2,2)),Color("b89a61"))

func button(action: String, caption: String, rect: Rect2) -> void:
	buttons[action] = rect
	var hover: bool = rect.has_point(get_global_mouse_position())
	draw_rect(rect,Color("6b7357") if hover else Color("30454b"))
	draw_rect(rect,Color("c7aa70"),false,1)
	var width: float = font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,9).x
	text_at(caption,Vector2(rect.position.x+(rect.size.x-width)/2,rect.position.y+16),9)

func draw_hearts(value: int) -> void:
	for i: int in range(3):
		var p := Vector2(17+i*16,48)
		var color: Color = Color("dc7a62") if i < value else Color("4a4d52")
		draw_rect(Rect2(p,Vector2(4,5)),color)
		draw_rect(Rect2(p+Vector2(5,0),Vector2(4,5)),color)
		draw_rect(Rect2(p+Vector2(-1,2),Vector2(11,4)),color)
		draw_rect(Rect2(p+Vector2(1,6),Vector2(7,2)),color)
		draw_rect(Rect2(p+Vector2(3,8),Vector2(3,2)),color)

func draw_map(rect: Rect2, full: bool = false) -> void:
	draw_rect(rect,Color("111e2c"))
	var discovery: Dictionary = State.discovered.get(State.region_id,{})
	var scale_x: float = rect.size.x/60.0
	var scale_y: float = rect.size.y/48.0
	var colors: Dictionary = {"village":Color("708259"),"forest":Color("4b775d"),"mountains":Color("b1c9d2"),"volcano":Color("685251"),"kitchen":Color("a38e71")}
	for key: String in discovery:
		var parts: PackedStringArray = key.split(",")
		var x: int = int(parts[0])
		var y: int = int(parts[1])
		var color: Color = colors[State.region_id]
		if State.region_id == "forest" and y >= 19 and y < 25: color = Color("477e94")
		if State.region_id == "mountains" and y >=13 and y <29: color = Color("34475d")
		draw_rect(Rect2(rect.position+Vector2(x*scale_x,y*scale_y),Vector2(scale_x+0.1,scale_y+0.1)),color)
	var actor: ChefPlayer = chef()
	var region: Node = actor.get_parent().get("region") if actor != null else null
	if region != null:
		for object: Node in region.get_children():
			if object is FeastInteractable and object.visible:
				var cell := Vector2i(object.position/16)
				if discovery.has(str(cell.x)+","+str(cell.y)) and object.kind in ["gate","ingredient","npc"]:
					var p: Vector2 = rect.position+object.position/Vector2(960,768)*rect.size
					draw_rect(Rect2(p-Vector2(1,1),Vector2(3,3)),Color("efc66d") if object.kind != "npc" else Color("dbd6b5"))
	var p: Vector2 = rect.position+State.chef_position/Vector2(960,768)*rect.size
	draw_rect(Rect2(p-Vector2(1,1),Vector2(3,3)),Color.WHITE)
	draw_rect(rect,Color("aa9066"),false,1)
	if full: text_at("White: chef    Gold: discovered landmark    Dark: unexplored",Vector2(rect.position.x,rect.end.y+16),8)

func _draw() -> void:
	buttons.clear()
	var player: ChefPlayer = chef()
	if player == null: return
	# Thin framed HUD preserves play space at the 640x360 internal resolution.
	draw_rect(Rect2(0,0,640,36),Color("1c2b32"))
	draw_line(Vector2(0,35),Vector2(640,35),Color("b29463"))
	text_at("A ROYAL FEAST",Vector2(14,15),10,Color("e7c681"))
	text_at(REGION_NAMES[State.region_id],Vector2(14,28),8,Color("c4d2c6"))
	text_at("ROYAL INGREDIENTS   %d / 3" % State.inventory.size(),Vector2(270,21),8)
	for i: int in range(3):
		var q: IngredientData = quests[i]
		draw_texture_rect(q.icon,Rect2(440+i*23,5,24,24),false,Color.WHITE if q.stable_id in State.inventory else Color(0.4,0.47,0.45,1))
	draw_hearts(player.health.current)
	panel(Rect2(522,45,108,82))
	draw_map(Rect2(527,50,98,64))
	text_at("M  MAP",Vector2(553,122),7)
	draw_rect(Rect2(0,337,640,23),Color("1c2b32"))
	draw_line(Vector2(0,337),Vector2(640,337),Color("8b7959"))
	text_at("WASD Move  LMB Whack  Shift Dodge  Space Jump  E Use",Vector2(12,350),7)
	text_at("H Hint  J Journal  Esc Pause",Vector2(438,350),7,Color("dbc18e"))
	if mode == "none":
		if is_instance_valid(player.interaction.target):
			panel(Rect2(155,305,330,23))
			center(player.interaction.target.prompt(),320,8)
		if toast_timer > 0:
			panel(Rect2(98,68,410,35))
			paragraph(toast,Vector2(111,81),386,8,Color("f3e6be"),11)
		if State.has_rock:
			text_at("STONE READY  |  RMB Throw",Vector2(14,75),8,Color("fff1b8"))
		var cursor: Vector2 = get_global_mouse_position()
		draw_line(cursor-Vector2(3,0),cursor+Vector2(3,0),Color("f9ecc8"))
		draw_line(cursor-Vector2(0,3),cursor+Vector2(0,3),Color("f9ecc8"))
	elif mode == "title":
		draw_rect(Rect2(0,0,640,360),Color(0.025,0.06,0.09,0.69))
		panel(Rect2(99,40,442,280))
		center("CHEF GAME",80,12,Color("d2b978"))
		center("A ROYAL FEAST",115,27,Color("f3e4b6"))
		center("An invitation. Three ingredients. One enormous spatula.",141,8,Color("a9c3b9"))
		for i: int in range(3):
			draw_texture_rect(quests[i].icon,Rect2(258+i*44,152,36,36),false)
		button("new","Begin a new adventure",Rect2(207,205,226,27))
		if FileAccess.file_exists(State.SAVE_PATH):
			button("continue","Continue your journey",Rect2(207,240,226,27))
		center("Explore freely. Ask questions. Experiment.",291,8,Color("b5c8b4"))
		center("A native Godot adventure  /  Art & audio: Pixel-boy + AAA",311,7,Color("8a9f98"))
	elif mode == "dialogue":
		panel(Rect2(67,212,506,114),true)
		text_at(dialogue_title.to_upper(),Vector2(83,232),9,Color("83503e"))
		paragraph(str(lines[line_index]),Vector2(83,253),470,9,Color("383c40"),14)
		text_at("E / SPACE / CLICK   Continue",Vector2(83,314),7,Color("7c6047"))
		text_at("%d / %d"%[line_index+1,lines.size()],Vector2(523,314),7,Color("7c6047"))
	elif mode == "journal":
		draw_rect(Rect2(0,36,640,301),Color(0.02,0.04,0.07,0.65))
		panel(Rect2(91,48,458,278),true)
		text_at("THE ROYAL INVITATION",Vector2(110,72),14,Color("784c3e"))
		paragraph("By royal decree: prepare His Majesty's birthday feast. Bring these three treasures to the Royal Kitchen.",Vector2(110,92),416,8)
		for i: int in range(3):
			var q: IngredientData = quests[i]
			var y: float = 133+i*48
			draw_texture_rect(q.icon,Rect2(110,y-9,30,30),false)
			text_at(("[FOUND] " if q.stable_id in State.inventory else "[  ] ")+q.display_name,Vector2(149,y+2),9,Color("4b5d44"))
			paragraph(q.clue,Vector2(149,y+16),366,8)
		text_at("All routes are open. The villagers' advice is optional.",Vector2(110,289),8,Color("76614b"))
		button("close","J / ESC  Close",Rect2(382,298,145,22))
		button("letter","Read royal letter",Rect2(110,298,189,22))
	elif mode == "map":
		draw_rect(Rect2(0,36,640,301),Color(0.02,0.04,0.07,0.8))
		panel(Rect2(131,43,378,283))
		center(REGION_NAMES[State.region_id].to_upper(),64,12)
		draw_map(Rect2(170,77,300,219),true)
		button("close","Close",Rect2(519,278,92,26))
	elif mode == "pause":
		draw_rect(Rect2(0,0,640,360),Color(0.02,0.04,0.07,0.72))
		panel(Rect2(194,59,252,253))
		center("A MOMENT'S REST",87,14)
		button("resume","Resume adventure",Rect2(218,104,204,26))
		button("save","Save journey",Rect2(218,139,204,26))
		button("sound","Sound: "+("off" if Sound.muted else "on"),Rect2(218,174,204,26))
		button("title","Return to title",Rect2(218,209,204,26))
		button("quit","Save & quit",Rect2(218,244,204,26))
		center("Your progress is saved automatically.",293,7)
	elif mode == "ending":
		draw_rect(Rect2(0,0,640,360),Color(0.025,0.04,0.07,minf(1,ending_clock/1.5)))
		if ending_clock > 1.5:
			center("THE INGREDIENTS HAVE BEEN GATHERED",132,15,Color("f0d49a"))
			center("The real cooking adventure is only beginning...",165,9)
			center("Prototype complete - thank you for playing!",213,9,Color("acc6ba"))
			button("title","Return to title",Rect2(234,247,172,28))
