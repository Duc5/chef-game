extends RefCounted
## Shared geometry and movement tuning for the authored wind course and safe saves.
const CHASM_TOP: float = 208.0
const CHASM_BOTTOM: float = 464.0
const CHECKPOINT: Vector2 = Vector2(480,492)
const HOVER_HEIGHT: float = 28.0
const RADIUS: float = 24.0
const JUMP_SPEED: float = 175.0
const PATTERNS: Array = [
	[Vector2(440,426),Vector2(536,336),Vector2(456,246)],
	[Vector2(520,426),Vector2(424,336),Vector2(504,246)],
	[Vector2(456,426),Vector2(544,336),Vector2(448,246)]
]
