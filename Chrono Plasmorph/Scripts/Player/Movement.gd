extends CharacterBody2D

# Declare variables for different gameplay mechanics and animations
@onready var Anim = %AnimatedSprite2D
@export var SPEED = 300.0  # Player movement speed
@export var JUMP_VELOCITY = -300.0  # Velocity applied when jumping
@export var DASH_SPEED = 600.0  # Speed multiplier during a dash
@export var DASH_DURATION = 0.05  # Duration of the dash
@onready var DashCoolDown = %DashTime
@onready var state = %State  # Node to display current state of the player
@export var game_manager: Node  # Reference to the game manager node

var dies = false  # Track death state
@export var pan_camera_limit = 0  # Placeholder for future camera-related functionality

# SFXs

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
var gravity = 980

# Wall jump limitation mechanics
var wall_jump_count = 0  # Tracks the number of wall jumps performed
@export var MAX_WALL_JUMPS = 3  # Maximum wall jumps allowed before resetting

var descending = false

func _ready():
	if game_manager != null:
		game_manager.set_checkpoint(position)
	else:
		print("Drag game manager into player's inspector.")

func _physics_process(delta):
	# Track the direction of the wall for wall jump logic
	prev_wall_direction = wall_direction
	wall_direction = get_wall_normal().x

	# Add gravity when not on the floor or sliding on a wall
	if not is_on_floor() and not is_wall_sliding:
		if Input.is_action_pressed("Down"):
			velocity.y += (gravity * 2) * delta
			descending = true
		else:
			descending = false
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
			SecondJump = false
	
	# Dash mechanics
	if Input.is_action_just_pressed("Dash") and not is_dashing and can_dash:
		if not is_wall_sliding or (is_wall_sliding and wall_jump_count == MAX_WALL_JUMPS - 1):
			dash_time = DASH_DURATION  # Start dash duration timer			
			if velocity.x > 0:
				is_dashing = true
				velocity.x = SPEED * (velocity.x / velocity.x) * DASH_SPEED
			elif velocity.x < 0:
				is_dashing = true
				velocity.x = SPEED * (velocity.x / velocity.x) * DASH_SPEED * - 1
			
			can_dash = false
			DashCoolDown.start()  # Start dash cooldown timer

	# Update dash timer
	if is_dashing:
		dash_time -= delta
		velocity.y = 0
		if dash_time <= 0:
			is_dashing = false  # End dash
			wall_jump_count = 0  # Reset wall jump count during dash
			SecondJump = false

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
	animationLogic()
	
	# Flip sprite direction based on horizontal movement
	if velocity.x > 0:
		Anim.flip_h = false
	elif velocity.x < 0:
		Anim.flip_h = true
	
	# To control player scale.
	scaleManger()


# Size Manager
func scaleManger():
	if Input.is_action_pressed("Shrink"):
		shrinks = true
		scales = false
		scaleBack = false
	elif Input.is_action_pressed("Scale"):
		shrinks = false
		scales = true
		scaleBack = false
	elif Input.is_action_pressed("ScaleBack"):
		scaleBack = true
		shrinks = false
		scales = false
	
	shrink_down()
	scale_up()
	scale_back()

var default_scale_x = scale.x
var default_scale_y = scale.y
var shrinks = false
var scales = false
var scaleBack = false

func shrink_down():
	if shrinks and not scales:
		scale.x = lerpf(scale.x, default_scale_x / 1.5, 0.1)
		scale.y = lerpf(scale.y, default_scale_y / 1.5, 0.1)
	
func scale_up():
	if scales and not shrinks:
		scale.x = lerpf(scale.x, default_scale_x * 2, 0.1)
		scale.y = lerpf(scale.y, default_scale_y * 2, 0.1)
		
func scale_back():
	if scaleBack and not shrinks and not scales:
		scale.x = lerpf(scale.x, default_scale_x, 0.1)
		scale.y = lerpf(scale.y, default_scale_y, 0.1)

# Controls player animation.
func animationManager(animation_name, animation_state):
	Anim.play(animation_name)
	state.text = animation_state

func animationLogic():
	if is_dashing:
		animationManager("Dash","Dashing")
	elif is_wall_sliding:
		animationManager("WallSlide","Sliding")
	elif velocity.y < 0 and not SecondJump:
		animationManager("JumpUp","Jumped")
	elif velocity.y < 0 and SecondJump:
		animationManager("FrontFlip","Flips")
	elif velocity.y > 0 and not descending:
		animationManager("JumpDown","Falling")
	elif velocity.y > 0 and descending:
		animationManager("Descending", "Descending")
	elif velocity.x != 0 and velocity.y == 0:
		animationManager("Run", "Running")
	else:
		if Anim.animation not in ["Appears", "Disappears"]:
			animationManager("Idle", "Idle")

func appear():
	Anim.visible = true  # Make the character visible
	state.text = "Spawns"
	Anim.play("Appears")

func disappear():
	state.text = "Disintegrate"
	Anim.play("Disappears")
	freeze()  # Stop physics processing

func dead():
	# Reset values to prevent glitches
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
				if game_manager != null:
					position = game_manager.get_checkpoint()  # Reset position to checkpoint
					Anim.visible = false
					appear()  # Trigger appear animation
					dies = false  # Reset death flag
				else:
					print("Drag game manager to player's inspector.")

# Movement related functions
func freeze():
	set_physics_process(false)  # Stop `_physics_process` execution
	velocity = Vector2.ZERO  # Stop movement
	position = global_position  # Keep the position static

func unfreeze():
	set_physics_process(true)  # Resume `_physics_process` execution
	velocity = Vector2.ZERO  # Reset velocity

# Dash timer manager.
func _on_dash_time_timeout():
	can_dash = true  # Reset dash ability after cooldown
