extends Camera2D

@export var player: CharacterBody2D

func _ready():
	drag_horizontal_offset = 1
	drag_vertical_offset = -1

func _process(delta):
	if player != null:
		is_dead(delta)
	else:
		print("Drag Player to the inspector.")

			
# Check if player is dead
func is_dead(delta):
	if player.dies == true:
		assignValue()
	else:
		shakeStrength = 0
	shake(delta)

# Shake camera when dying
var randomStrength = 5.0
var shakeFade = 2.0
var rng = RandomNumberGenerator.new()
var shakeStrength = 0.0

func assignValue():
	shakeStrength = randomStrength

func shake(delta):
	if shakeStrength > 0:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		offset = Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength,shakeStrength))
