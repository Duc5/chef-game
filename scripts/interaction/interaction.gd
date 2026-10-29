class_name InteractionComponent
extends Node

# sits on the chef and works out which interactable is "the one" right now,
# so pressing E always does something predictable even when a villager,
# a stone and a gate are all close together

signal target_changed(target: Node2D)

@export var reach: float = 34.0

var target: Node2D


## picks the best interactable in reach and moves the highlight onto it.
## the player calls this every frame with whichever way the chef is facing
func scan(actor: Node2D, facing: Vector2) -> void:
	var best: Node2D = null
	var score: float = INF

	for candidate: Node2D in get_tree().get_nodes_in_group("interactable"):

		# skips anything already collected / hidden
		if not candidate.eligible():
			continue

		var offset: Vector2 = candidate.global_position - actor.global_position
		var distance: float = offset.length()

		# closest wins, but things in front of the chef get a small bonus
		# so you don't grab the thing behind you by accident
		var candidate_score: float = distance - facing.dot(offset.normalized()) * 5.0

		# extra_reach lets big things like gates and the counter be
		# usable from a bit further away than a tiny stone
		if distance <= reach + candidate.extra_reach and candidate_score < score:
			best = candidate
			score = candidate_score

	# only touch highlights and send the signal when the target actually
	# changes, otherwise the bottom bar would get updated every single frame
	if best != target:

		if is_instance_valid(target):
			target.highlight(false)

		target = best

		if is_instance_valid(target):
			target.highlight(true)

		target_changed.emit(target)


## interacts with the current target when E is pressed. checks again that it's
## still valid because it might have been collected since the last scan
func activate(actor: Node2D) -> void:
	if is_instance_valid(target) and target.eligible():
		target.interact(actor)
