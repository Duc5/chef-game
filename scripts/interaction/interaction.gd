class_name InteractionComponent
extends Node
signal target_changed(target: Node2D)
var target: Node2D
@export var reach: float = 34.0

func scan(actor: Node2D, facing: Vector2) -> void:
	var best: Node2D = null
	var score: float = INF
	for candidate: Node2D in get_tree().get_nodes_in_group("interactable"):
		if not candidate.eligible():
			continue
		var offset: Vector2 = candidate.global_position-actor.global_position
		var distance: float = offset.length()
		var candidate_score: float = distance - facing.dot(offset.normalized())*5.0
		if distance <= reach+candidate.extra_reach and candidate_score < score:
			best = candidate
			score = candidate_score
	if best != target:
		if is_instance_valid(target):
			target.highlight(false)
		target = best
		if is_instance_valid(target):
			target.highlight(true)
		target_changed.emit(target)

func activate(actor: Node2D) -> void:
	if is_instance_valid(target) and target.eligible():
		target.interact(actor)
