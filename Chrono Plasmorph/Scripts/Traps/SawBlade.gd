extends Area2D

# Very similar to unity, where we get a gameobject field.
# We can then drag our gameobject and call their functions.
@export var player: CharacterBody2D

func _on_body_entered(body):
	# For future reference, we check if whatever scene entered has the name "Player"
	if body.name == "Player":
		# For future reference again, this code ensures that it will not run.
		# Unless, the game object for player has been fulfilled.
		if player != null:
			player.dead()
		else:
			print("Drag the player scene to player field (inspector).")
