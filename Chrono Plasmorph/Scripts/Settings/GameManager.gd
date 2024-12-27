extends Node

# This node serves as useful function holder.
# We just reference it from other scene and we can use the function inside.

# Holds the point.
var point = 0

# Score Label: to be removed in the future.
@onready var score = %Score

# Stores the position of the Checkpoint Object so Player can teleport to it when they die.
var current_checkpoint: Vector2 = Vector2()  # Store the checkpoint position

func add_point():
	point += 1
	score.text = "Score: {0}".format([point])

# Now current_checkpoint has become useful here.
func set_checkpoint(checkpoint: Vector2):
	print("Checkpoint set to: " + str(checkpoint))
	current_checkpoint = checkpoint

# We use this for getting the Vector2 and then we assign it on the player position
func get_checkpoint() -> Vector2:
	return current_checkpoint
