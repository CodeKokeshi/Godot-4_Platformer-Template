extends Area2D

# Aight, I'm gonna fix this later, this shouldn't be written for local but the game manager should be a game object
@export var game_manager: Node
@onready var animated_sprite_2d = $BananaAnim
var collected = false

func _on_body_entered(body):
	if (body.name == "Player"):
		if collected == false:
			game_manager.add_point()
			collected = true
		animated_sprite_2d.play("Collected")

func _on_banana_anim_animation_finished():
	# queue_free destroys the scene.
	queue_free()
