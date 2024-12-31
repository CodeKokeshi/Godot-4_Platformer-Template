extends CharacterBody2D

func _physics_process(delta):
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		queue_free()
	else:
		velocity.x = 500 * -1
	move_and_slide()
