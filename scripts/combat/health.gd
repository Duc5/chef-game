class_name HealthComponent
extends Node

# shared health node used by the chef and every enemy, so taking damage,
# i-frames and dying all work the same everywhere. add it as a child
# called Health and hook into changed (for the hud hearts) and depleted

signal changed(value: int)
signal depleted

@export var maximum: int = 3

var current: int = 3
var invulnerability: float = 0.0


func _ready() -> void:
	current = maximum


func _process(delta: float) -> void:
	# i-frames don't tick down while dialogue / journal / map are open,
	# otherwise the chef could lose their protection while reading
	if not State.controls_locked:
		invulnerability = maxf(0.0, invulnerability - delta)


## takes amount off current health. returns false if the hit didn't count
## (still in i-frames or already at zero) so callers can skip the knockback and sfx
func hurt(amount: int = 1) -> bool:
	if invulnerability > 0.0 or current <= 0:
		return false

	current = maxi(0, current - amount)

	# grace window after each hit, stops a barkling stood on top of the
	# chef from draining every heart in a few frames
	invulnerability = 1.2

	changed.emit(current)

	if current == 0:
		depleted.emit()

	return true


## tops the chef back up to full after a respawn. i-frames are a bit longer
## than a normal hit so you don't get clipped by an imp the moment you're back
func restore() -> void:
	current = maximum
	invulnerability = 1.5

	changed.emit(current)
