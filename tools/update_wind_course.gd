extends Node
## Targeted map migration: preserve hand edits in all other regions.
const WindRules = preload("res://scripts/puzzles/wind_course.gd")

func _ready() -> void:
	var region: Node2D = load("res://scenes/regions/mountains.tscn").instantiate()
	region.scene_file_path = ""
	var terrain: TileMapLayer = region.get_node("Terrain")
	for y: int in range(13,29):
		for x: int in range(60):
			terrain.set_cell(Vector2i(x,y),0,Vector2i(5,0))
	region.get_node("RockPile").position = Vector2(427,494)
	region.get_node("ReserveRocks").position = Vector2(480,467)
	region.get_node("Chimes").position = Vector2(554,494)
	region.get_node("Egg").position = Vector2(480,166)
	for i: int in range(3):
		region.get_node("Wind%d"%i).position = WindRules.PATTERNS[0][i]
	for child: Node in region.get_children():
		if child is Label:
			if child.text == "WHISPERING CHASM": child.position.y = 528
			if child.text == "THE SKYFEATHER NEST": child.position.y = 124
		if child is Node2D and child.position.y > WindRules.CHASM_TOP-24 and child.position.y < WindRules.CHASM_BOTTOM+24:
			# Repeated scenery names may be auto-renamed by Godot; identify their art/shape.
			var scenery_sprite: bool = child is Sprite2D and child.texture != null and child.texture.resource_path.ends_with("/nature.png")
			var scenery_collider: bool = child is StaticBody2D and child.has_node("Collision") and child.get_node("Collision").shape is RectangleShape2D and child.get_node("Collision").shape.size == Vector2(12,9)
			if scenery_sprite or scenery_collider:
				child.free()
	var scene := PackedScene.new()
	var result: Error = scene.pack(region)
	if result == OK:
		result = ResourceSaver.save(scene,"res://scenes/regions/mountains.tscn")
	region.free()
	print("WIND_MAP_UPDATE: ",error_string(result))
	get_tree().quit(0 if result == OK else 1)
