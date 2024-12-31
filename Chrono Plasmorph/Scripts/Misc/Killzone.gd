extends Area2D

@export var player: CharacterBody2D

func _on_body_entered(body):
	if body.name == "Player":
		if player != null:
			player.dead()
		else:
			print("Drag the player scene to player field (inspector).")
