extends Area2D

# This is one example of how we use game manager.
@export var game_manager: Node

var checkpoint_set = false

# To be removed in the future.
@onready var state = $State

func _on_body_entered(body):
	if body.name == "Player" and not checkpoint_set:
		if game_manager != null:
			# Then we use it here, we get the position of this scene then set it as checkpoint in the parameter.
			game_manager.set_checkpoint(position)
			checkpoint_set = true
			# Like I said above, this is to be removed in the future, it's, just for now, serves as debugger. 
			state.text = "Activated"
