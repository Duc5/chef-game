class_name HealthComponent
extends Node
signal changed(value: int)
signal depleted
@export var maximum: int = 3
var current: int = 3
var invulnerability: float = 0.0

func _ready() -> void:
	current = maximum

func _process(delta: float) -> void:
	if not State.controls_locked:
		invulnerability = maxf(0.0, invulnerability-delta)

func hurt(amount: int = 1) -> bool:
	if invulnerability > 0.0 or current <= 0:
		return false
	current = maxi(0,current-amount)
	invulnerability = 1.2
	changed.emit(current)
	if current == 0:
		depleted.emit()
	return true

func restore() -> void:
	current = maximum
	invulnerability = 1.5
	changed.emit(current)
