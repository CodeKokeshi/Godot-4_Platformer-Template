extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var label = $Label

const jump_power = -300
const gravity = 980

func _physics_process(delta):
	if is_on_floor() and is_on_wall():
		velocity.y = jump_power
		velocity.x = direction * move_speed
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
	
func _process(delta):
	if velocity.x != 0:
		animated_sprite_2d.play("run")
		label.text = "A.I Moving"
	elif velocity.x == 0:
		animated_sprite_2d.play("default")
		label.text = "A.I Thinking"
	
	if velocity.y < 0:
		animated_sprite_2d.play("jump")
		label.text = "A.I Error"
	elif velocity.y > 0:
		animated_sprite_2d.play("fall")
		label.text = "A.I Error"
		
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true

var direction = 1
var move_speed = 1

func move(dir, speed):
	velocity.x = dir * speed
	direction = dir
	move_speed = speed
	
func check_for_self(node):
	if node == self:
		return true
	else:
		return false
