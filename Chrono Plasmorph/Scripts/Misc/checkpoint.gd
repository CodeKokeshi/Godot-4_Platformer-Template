extends Area2D

# This is one example of how we use game manager.
@export var game_manager: Node
@onready var animated_sprite_2d = $AnimatedSprite2D

var checkpoint_set = false

func _process(delta):
	if checkpoint_set == true:
		animated_sprite_2d.play("Activated")

func _on_body_entered(body):
	if body.name == "Player" and not checkpoint_set:
		if game_manager != null:
			# Then we use it here, we get the position of this scene then set it as checkpoint in the parameter.
			game_manager.set_checkpoint(position)
			checkpoint_set = true
