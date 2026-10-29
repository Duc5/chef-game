extends RefCounted

## every number for the wind crossing over the chasm lives here, so the player,
## updrafts, thrown stones and saving all agree on the same values.
## tweak these to tune the crossing instead of hunting through four scripts

# the strip of map that counts as "over the chasm"
const CHASM_TOP: float = 208.0
const CHASM_BOTTOM: float = 464.0

# safe spot just below the chasm. the chef goes back here (and saves here)
# so you never respawn or load in mid air
const CHECKPOINT: Vector2 = Vector2(480, 492)

# how high the chef floats in an updraft, how close you need to be to count
# as inside one, and how big the hop is when jumping off one
const HOVER_HEIGHT: float = 28.0
const RADIUS: float = 24.0
const JUMP_SPEED: float = 175.0

# the possible updraft layouts, bottom to top. each one zig zags across the
# chasm so you can't just jump straight up the middle
const PATTERNS: Array = [
	[Vector2(440, 426), Vector2(536, 336), Vector2(456, 246)],
	[Vector2(520, 426), Vector2(424, 336), Vector2(504, 246)],
	[Vector2(456, 426), Vector2(544, 336), Vector2(448, 246)],
]
