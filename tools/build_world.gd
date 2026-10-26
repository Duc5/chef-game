extends Node
const WindRules = preload("res://scripts/puzzles/wind_course.gd")
## Bake the handcrafted regions into ordinary, editable .tscn files.
var root_node: Node2D
var terrain: TileMapLayer
var props: Node2D
var rng := RandomNumberGenerator.new()
var terrain_set: TileSet
var font: Font = preload("res://assets/game/font.ttf")

func _ready() -> void:
	call_deferred("build")

func build() -> void:
	rng.seed = 42
	make_tileset()
	for id: String in ["village","forest","mountains","volcano","kitchen"]:
		make_region(id)
	print("WORLD_BUILD_OK: five native scenes baked.")
	get_tree().quit()

func make_tileset() -> void:
	terrain_set = TileSet.new()
	terrain_set.tile_size = Vector2i(16,16)
	var source := TileSetAtlasSource.new()
	source.texture = preload("res://assets/custom/terrain.svg")
	source.texture_region_size = Vector2i(16,16)
	for x: int in range(8): source.create_tile(Vector2i(x,0))
	terrain_set.add_source(source,0)
	ResourceSaver.save(terrain_set,"res://assets/custom/terrain.tres")

func own(node: Node) -> void:
	node.owner = root_node
	for child: Node in node.get_children(): own(child)

func solid(name_text: String, pos: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = name_text
	body.position = pos
	var shape := CollisionShape2D.new()
	shape.name = "Collision"
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
	root_node.add_child(body)
	return body

func sprite(name_text: String, pos: Vector2, file: String, rect: Rect2 = Rect2()) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = name_text
	s.position = pos
	s.texture = load("res://assets/"+file)
	if rect.size != Vector2.ZERO:
		s.region_enabled = true
		s.region_rect = rect
	root_node.add_child(s)
	return s

func sign_text(text_value: String, pos: Vector2, colour: Color = Color("f2dfac")) -> void:
	var label := Label.new()
	label.position = pos
	label.text = text_value
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",8)
	label.add_theme_color_override("font_color",colour)
	label.add_theme_color_override("font_shadow_color",Color("303849"))
	label.add_theme_constant_override("shadow_offset_y",1)
	root_node.add_child(label)

func object(name_text: String, pos: Vector2, kind: String, id: String, caption: String, file: String, rect: Rect2 = Rect2(), script_path: String = "") -> Node2D:
	var n: Node2D = preload("res://scenes/objects/interactable.tscn").instantiate()
	n.scene_file_path = ""
	n.name = name_text
	if script_path != "": n.set_script(load("res://scripts/"+script_path+".gd"))
	n.position = pos
	n.kind = kind
	n.stable_id = id
	n.display_name = caption
	n.get_node("Sprite").texture = load("res://assets/"+file)
	if rect.size != Vector2.ZERO:
		n.get_node("Sprite").region_enabled = true
		n.get_node("Sprite").region_rect = rect
	root_node.add_child(n)
	return n

func npc(id: String, caption: String, pos: Vector2) -> void:
	object(id.capitalize(),pos,"npc",id,caption,"game/"+id+".png",Rect2(0,0,16,16))
	sign_text(caption,pos+Vector2(-24,-34))

func gate(destination: String, caption: String, pos: Vector2) -> void:
	var n: Node2D = object(destination.capitalize()+"Gate",pos,"gate",destination,caption,"game/house.png",Rect2(136,100,16,20))
	n.destination = destination
	n.extra_reach = 6
	sign_text(caption,pos+Vector2(-36,-37))

func path_line(a: Vector2i, b: Vector2i, half_width: int = 2) -> void:
	var steps: int = maxi(absi(b.x-a.x),absi(b.y-a.y))
	for i: int in range(steps+1):
		var c := Vector2i(Vector2(a).lerp(Vector2(b),float(i)/maxi(steps,1)))
		for y: int in range(-half_width,half_width+1):
			for x: int in range(-half_width,half_width+1):
				terrain.set_cell(c+Vector2i(x,y),0,Vector2i(1,0))

func enemy(pos: Vector2, id: String, bark: bool = false) -> void:
	var n: Node2D = preload("res://scenes/actors/enemy.tscn").instantiate()
	n.scene_file_path = ""
	n.name = id
	n.position = pos
	n.enemy_id = id
	n.barkling = bark
	if bark:
		n.get_node("Sprite").texture = preload("res://assets/game/nature.png")
		n.get_node("Sprite").region_rect = Rect2(0,128,32,32)
	root_node.add_child(n)

func make_region(id: String) -> void:
	root_node = Node2D.new()
	root_node.name = id.capitalize()
	root_node.set_script(preload("res://scripts/world/region.gd"))
	root_node.region_id = id
	terrain = TileMapLayer.new()
	terrain.name = "Terrain"
	terrain.tile_set = terrain_set
	root_node.add_child(terrain)
	var tile_id: int = {"village":0,"forest":0,"mountains":2,"volcano":3,"kitchen":7}[id]
	for y: int in range(48):
		for x: int in range(60): terrain.set_cell(Vector2i(x,y),0,Vector2i(tile_id,0))
	# Separate layer available for authoring foreground additions inside Godot.
	var foreground := TileMapLayer.new()
	foreground.name = "Foreground"
	foreground.tile_set = terrain_set
	foreground.z_index = 8
	root_node.add_child(foreground)
	solid("NorthBoundary",Vector2(480,18),Vector2(960,36))
	solid("SouthBoundary",Vector2(480,758),Vector2(960,20))
	solid("WestBoundary",Vector2(8,384),Vector2(16,768))
	solid("EastBoundary",Vector2(952,384),Vector2(16,768))
	if id == "village": village()
	if id == "forest": forest()
	if id == "mountains": mountains()
	if id == "volcano": volcano()
	if id == "kitchen": kitchen()
	decorate(id)
	for child: Node in root_node.get_children(): own(child)
	var scene := PackedScene.new()
	scene.pack(root_node)
	ResourceSaver.save(scene,"res://scenes/regions/"+id+".tscn")
	root_node.free()

func village() -> void:
	path_line(Vector2i(30,6),Vector2i(30,44))
	path_line(Vector2i(14,24),Vector2i(54,24))
	path_line(Vector2i(16,30),Vector2i(30,30),1)
	path_line(Vector2i(30,38),Vector2i(53,38),1)
	var building_i: int = 0
	for p: Vector2 in [Vector2(240,435),Vector2(385,280),Vector2(650,270),Vector2(675,520)]:
		sprite("Cottage",p,"game/house.png",Rect2(128 if building_i%2 == 1 else 0,0,64,64))
		solid("HouseWall",p+Vector2(0,9),Vector2(50,27))
		building_i += 1
	sign_text("CHEF'S COTTAGE",Vector2(195,456))
	sign_text("BRAMBLEWICK",Vector2(430,330),Color("ffefb2"))
	sprite("Well",Vector2(530,435),"game/house.png",Rect2(0,240,48,48))
	solid("WellWall",Vector2(530,438),Vector2(26,16))
	object("Letter",Vector2(286,500),"letter","letter","Open royal letter","custom/letter.svg")
	npc("rowan","Elder Rowan",Vector2(424,375))
	npc("mira","Mira",Vector2(438,190))
	npc("flint","Flint",Vector2(643,585))
	object("Child",Vector2(353,470),"inspect","child","Talk · Child","game/child.png",Rect2(0,0,16,16)).description = "Child: Is that a sword? No, wait... Is that a spatula?! Can you make pancakes with it?"
	gate("forest","Riverwood  >",Vector2(860,380))
	gate("mountains","^  Whispering Peaks",Vector2(480,100))
	gate("volcano","Emberfall  >",Vector2(840,612))
	gate("kitchen","Royal Kitchen  v",Vector2(480,694))
	# Pack farming props, consistent 16px density.
	for y: int in range(3):
		for x: int in range(6):
			sprite("Crops",Vector2(180+x*18,200+y*18),"game/nature.png",Rect2(144,208,16,16))

func forest() -> void:
	path_line(Vector2i(30,43),Vector2i(30,26))
	path_line(Vector2i(30,33),Vector2i(22,33),1)
	path_line(Vector2i(26,17),Vector2i(34,17),2)
	for y: int in range(19,25):
		for x: int in range(60): terrain.set_cell(Vector2i(x,y),0,Vector2i(4,0))
	solid("RiverLeft",Vector2(231,352),Vector2(462,96))
	solid("RiverRight",Vector2(729,352),Vector2(462,96))
	solid("RiverGap",Vector2(480,352),Vector2(36,96))
	var tree: Node2D = object("WeakenedOak",Vector2(480,426),"tree","forest_tree","Inspect weakened oak","game/nature.png",Rect2(64,32,64,48),"puzzles/tree_puzzle")
	tree.extra_reach = 9
	tree.get_node("Sprite").position.y = -24
	sprite("FallenBridge",Vector2(480,366),"custom/bridge.svg")
	var mushroom: Node2D = object("Mushroom",Vector2(480,245),"ingredient","mushroom","Dewcrown Mushroom","custom/mushroom.svg")
	mushroom.requires_flag = "forest_bridge"
	npc("bram","Bram",Vector2(355,540))
	object("OldAxe",Vector2(400,460),"inspect","axe","Inspect old axe","game/nature.png",Rect2(80,128,16,16)).description = "A rusted axe. Your enormous spatula looks rather sturdier."
	object("Stones",Vector2(562,446),"inspect","stones","Inspect stones","custom/rock.svg").description = "A pile of river stones. The oak already leans towards the island."
	enemy(Vector2(480,596),"barkling",true)
	gate("village","Bramblewick  v",Vector2(480,718))
	sign_text("THE ANCIENT RIVER",Vector2(410,474))
	sign_text("LUMBER CAMP",Vector2(290,572))

func mountains() -> void:
	path_line(Vector2i(30,43),Vector2i(30,30),2)
	for y: int in range(13,29):
		for x: int in range(60): terrain.set_cell(Vector2i(x,y),0,Vector2i(5,0))
	object("RockPile",Vector2(427,494),"rock","rocks","Loose stones","custom/rock.svg")
	object("ReserveRocks",Vector2(480,467),"rock","rocks2","Loose stones","custom/rock.svg")
	object("Chimes",Vector2(554,494),"inspect","chimes","Listen to wind chimes","game/house.png",Rect2(136,100,16,20)).description = "The chimes tremble in the wind. Snowflakes vanish into the chasm, then rise again."
	for i: int in range(3):
		var wind: Node2D = preload("res://scenes/objects/updraft.tscn").instantiate()
		wind.scene_file_path = ""
		wind.name = "Wind%d"%i
		wind.position = WindRules.PATTERNS[0][i]
		root_node.add_child(wind)
	object("Egg",Vector2(480,166),"ingredient","egg","Skyfeather Egg","custom/egg.svg")
	gate("village","Bramblewick  v",Vector2(480,718))
	sign_text("WHISPERING CHASM",Vector2(410,528),Color("4b6579"))
	sign_text("THE SKYFEATHER NEST",Vector2(407,124),Color("4b6579"))

func volcano() -> void:
	for y: int in range(48):
		for x: int in range(60):
			if x < 11 or x > 48:
				terrain.set_cell(Vector2i(x,y),0,Vector2i(6,0))
	solid("LavaWest",Vector2(84,384),Vector2(168,768))
	solid("LavaEast",Vector2(876,384),Vector2(168,768))
	for x: int in [228,732]:
		for y: int in [240,420,590]:
			sprite("Pillar",Vector2(x,y),"game/nature.png",Rect2(240,0,32,32))
	var spout: Node2D = object("Spout",Vector2(365,387),"inspect","spout","Inspect ancient fire spout","custom/spout.svg")
	spout.description = "Fire returned shall wake the forge. The spout will keep firing even if every imp is defeated."
	for i: int in range(3):
		object("Switch%d"%i,Vector2(384+i*96,304),"inspect","furnace_%d"%i,"Inspect furnace emblem","custom/switch.svg",Rect2(),"puzzles/furnace_switch").description = "A dark metal emblem, shaped like a flame. Scorch marks surround it."
	# A full-width barrier keeps the greenhouse physically sealed until all switches awaken.
	solid("GreenhouseBarrier",Vector2(480,233),Vector2(624,20))
	sprite("ForgeDoor",Vector2(480,223),"custom/door.svg")
	object("Pepper",Vector2(480,150),"ingredient","pepper","Cinderheart Pepper","custom/pepper.svg").requires_flag = "greenhouse_open"
	enemy(Vector2(610,440),"forge_imp")
	enemy(Vector2(565,610),"entrance_imp")
	gate("village","Bramblewick  v",Vector2(480,718))
	sign_text("FIRE RETURNED SHALL WAKE THE FORGE",Vector2(344,486))
	sign_text("CINDERHEART GREENHOUSE",Vector2(388,95),Color("c1d999"))

func kitchen() -> void:
	for y: int in range(48):
		for x: int in range(60):
			if x < 12 or x > 47 or y < 6:
				terrain.set_cell(Vector2i(x,y),0,Vector2i(3,0))
	solid("KitchenWest",Vector2(150,384),Vector2(84,768))
	solid("KitchenEast",Vector2(810,384),Vector2(84,768))
	solid("KitchenNorth",Vector2(480,90),Vector2(576,20))
	for x: int in range(260,740,64):
		sprite("Pantry",Vector2(x,140),"game/house.png",Rect2(464,0,32,48))
	for x: int in [270,690]:
		for y: int in [270,420]:
			sprite("KitchenTable",Vector2(x,y),"custom/counter.svg")
	object("PreparationCounter",Vector2(480,290),"counter","counter","Present Ingredients","custom/counter.svg")
	solid("CounterBody",Vector2(480,287),Vector2(78,24))
	npc("quill","Steward Quill",Vector2(530,380))
	sign_text("THE ROYAL KITCHEN",Vector2(410,215))
	sign_text("His Majesty's birthday feast",Vector2(380,235))
	gate("village","Bramblewick  v",Vector2(480,718))

func decorate(id: String) -> void:
	if id == "kitchen": return
	# Low plants soften path edges without introducing collision or hiding clues.
	if id in ["village","forest"]:
		for i: int in range(140):
			var p := Vector2(rng.randi_range(28,932),rng.randi_range(65,728))
			if id == "forest" and p.y > 286 and p.y < 410: continue
			if absf(p.x-480)<42 or (id == "village" and absf(p.y-380)<42): continue
			sprite("Wildflowers",p,"game/nature.png",Rect2((i%4)*16,160+(i%2)*16,16,16))
	for i: int in range(170):
		var p := Vector2(rng.randi_range(40,920),rng.randi_range(55,725))
		# Keep the central navigation corridors, interactables and puzzles legible.
		if absf(p.x-480)<105 or (id == "village" and (absf(p.y-380)<64 or absf(p.y-612)<44)):
			continue
		if id == "forest" and p.y > 275 and p.y < 485: continue
		if id == "mountains" and p.y > WindRules.CHASM_TOP-24 and p.y < WindRules.CHASM_BOTTOM+24: continue
		if id == "volcano" and p.x > 190 and p.x < 770: continue
		var rect: Rect2 = Rect2(0,0,32,32)
		if id == "forest": rect = Rect2(32,0,32,32)
		if id == "mountains": rect = Rect2(128,0,32,32)
		if id == "volcano": rect = Rect2(272,160,48,48)
		if i%3 == 0: rect = Rect2(16*(i%6),160,16,16)
		var s: Sprite2D = sprite("Scenery",p,"game/nature.png",rect)
		if rect.size.x >= 32:
			solid("SceneryTrunk",p+Vector2(0,11),Vector2(12,9))
		if id == "volcano": s.modulate = Color("b68c86")
