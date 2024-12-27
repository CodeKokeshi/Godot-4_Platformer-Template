extends CharacterBody2D

# Declare variables for different gameplay mechanics and animations
@onready var Anim = %AnimatedSprite2D
@export var SPEED = 300.0  # Player movement speed
@export var JUMP_VELOCITY = -300.0  # Velocity applied when jumping
@export var DASH_SPEED = 600.0  # Speed multiplier during a dash
@export var DASH_DURATION = 0.05  # Duration of the dash
@onready var DashCoolDown = %DashTime
@onready var state = %State  # Node to display current state of the player

@export var pan_camera_limit = 0  # Placeholder for future camera-related functionality

# Double jump and dash mechanics
var SecondJump = false
var is_dashing = false
var dash_time = 0
var can_dash = true

# Variables for jump buffering and coyote time mechanics
@export var COYOTE_TIME = 0.2  # Duration after leaving the ground to still allow jumping
@export var JUMP_BUFFER_TIME = 0.2  # Time window to register a jump input before landing
var coyote_timer = 0.0
var jump_buffer_timer = 0.0

# Variables for wall sliding and jumping mechanics
var prev_wall_direction = 0
var wall_direction = 0
@export var WALL_JUMP_PUSHBACK = 400.0  # Horizontal pushback force during a wall jump
@export var WALL_JUMP_VERTICAL = -350.0  # Vertical velocity during a wall jump

@export var WALL_SLIDE_SPEED = 50.0  # Speed while sliding down a wall
@export var WALL_JUMP_VELOCITY = Vector2(-250.0, -300.0)  # Horizontal and vertical velocity for wall jumps
var is_wall_sliding = false

# Gravity variable synced with project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Wall jump limitation mechanics
var wall_jump_count = 0  # Tracks the number of wall jumps performed
@export var MAX_WALL_JUMPS = 3  # Maximum wall jumps allowed before resetting

func _physics_process(delta):
	# Track the direction of the wall for wall jump logic
	prev_wall_direction = wall_direction
	wall_direction = get_wall_normal().x

	# Add gravity when not on the floor or sliding on a wall
	if not is_on_floor() and not is_wall_sliding:
		velocity.y += gravity * delta
	coyote_timer -= delta

	# Reset mechanics when the player is on the floor
	if is_on_floor():
		coyote_timer = COYOTE_TIME  # Reset coyote time
		SecondJump = false  # Allow double jump again
		wall_jump_count = 0  # Reset wall jump count

	# Check for wall sliding
	is_wall_sliding = false
	if is_on_wall() and not is_on_floor() and velocity.y > 0 and wall_jump_count < MAX_WALL_JUMPS:
		is_wall_sliding = true
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)  # Limit sliding speed

	# Register jump input using jump buffering
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME  # Start the jump buffer timer

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# Jump logic with coyote time, jump buffer, double jump, and wall jump
	if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0) and not is_wall_sliding:
		velocity.y = JUMP_VELOCITY  # Perform a regular jump
		jump_buffer_timer = 0
	elif jump_buffer_timer > 0 and not is_on_floor() and not SecondJump:
		velocity.y = JUMP_VELOCITY  # Perform a double jump
		SecondJump = true
		jump_buffer_timer = 0
	elif jump_buffer_timer > 0 and is_wall_sliding:
		if wall_jump_count < MAX_WALL_JUMPS:
			velocity.x = 0  # Reset horizontal velocity for clean wall jump
			velocity.y = WALL_JUMP_VERTICAL  # Apply vertical velocity for wall jump
			velocity.x = -prev_wall_direction * WALL_JUMP_PUSHBACK  # Apply horizontal pushback
			wall_jump_count += 1  # Increment wall jump count
			jump_buffer_timer = 0

	# Dash mechanics
	if Input.is_action_just_pressed("Dash") and not is_dashing and can_dash:
		if not is_wall_sliding or (is_wall_sliding and wall_jump_count == MAX_WALL_JUMPS - 1):
			is_dashing = true
			dash_time = DASH_DURATION  # Start dash duration timer
			velocity.x = SPEED * (velocity.x / abs(velocity.x) if velocity.x != 0 else 1) * DASH_SPEED
			can_dash = false
			DashCoolDown.start()  # Start dash cooldown timer

	# Update dash timer
	if is_dashing:
		wall_jump_count = 0  # Reset wall jump count during dash
		dash_time -= delta
		velocity.y = 0  # Lock vertical velocity during dash
		if dash_time <= 0:
			is_dashing = false  # End dash

	# Handle player movement
	if not is_dashing:  # Prevent normal movement while dashing
		var direction = Input.get_axis("Left", "Right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)  # Smooth deceleration

	move_and_slide()  # Apply movement and handle collisions

func _process(delta):
	# Update animations and state text based on player actions
	if is_dashing:
		Anim.play("Dash")
		state.text = "Dashing"
	elif is_wall_sliding:
		Anim.play("WallSlide")
		state.text = "Sliding"
	elif velocity.y < 0 and not SecondJump:
		Anim.play("JumpUp")
		state.text = "Jumped"
	elif velocity.y < 0 and SecondJump:
		Anim.play("FrontFlip")
		state.text = "Flips"
	elif velocity.y > 0:
		Anim.play("JumpDown")
		state.text = "Falling"
	elif velocity.x != 0 and velocity.y == 0:
		Anim.play("Run")
		state.text = "Running"
	else:
		if Anim.animation not in ["Appears", "Disappears"]:
			Anim.play("Idle")
			state.text = "Idle"

	# Flip sprite direction based on horizontal movement
	if velocity.x > 0:
		Anim.flip_h = false
	elif velocity.x < 0:
		Anim.flip_h = true

	# Handle appear/disappear actions
	if Input.is_action_pressed("Appear"):
		appear()
	if Input.is_action_pressed("Disappear"):
		disappear()

func _on_dash_time_timeout():
	can_dash = true  # Reset dash ability after cooldown

func appear():
	Anim.visible = true  # Make the character visible
	state.text = "Spawns"
	Anim.play("Appears")

func disappear():
	state.text = "Disintegrate"
	Anim.play("Disappears")
	freeze()  # Stop physics processing

func dead():
	is_wall_sliding = false  # Disable wall sliding on death
	wall_jump_count = 0
	
	is_dashing = false  # Disable dashing on death
	can_dash = true
	dash_time = 0
	
	SecondJump = false
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	
	velocity = Vector2.ZERO  # Reset velocity
	
	dies = true
	
	disappear()  # Trigger disappear animation

@export var game_manager: Node  # Reference to the game manager node

var dies = false  # Track death state

func _on_animated_sprite_2d_animation_finished():
	# Handle actions after animations finish
	if not dies:
		match Anim.animation:
			"Appears":
				Anim.play("Idle")
				unfreeze()
			"Disappears":
				Anim.visible = false
	else:
		match Anim.animation:
			"Appears":
				Anim.play("Idle")
				unfreeze()
			"Disappears":
				position = game_manager.get_checkpoint()  # Reset position to checkpoint
				Anim.visible = false
				appear()  # Trigger appear animation
				dies = false  # Reset death flag

func freeze():
	set_physics_process(false)  # Stop `_physics_process` execution
	velocity = Vector2.ZERO  # Stop movement
	position = global_position  # Keep the position static

func unfreeze():
	set_physics_process(true)  # Resume `_physics_process` execution
	velocity = Vector2.ZERO  # Reset velocity
