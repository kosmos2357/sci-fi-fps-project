extends CharacterBody3D

const BULLET_SCENE = preload("res://features/player/scenes/bullet.tscn")
# --- Variables ---
# How fast the player moves
@export var SPEED = 7.0
@export var SPRINT_SPEED = 2
@export var JUMP_VELOCITY = 7.0
@export var FRICTION = 10
@export var ACCELERATION = 12
# How sensitive the mouse is
@export var MOUSE_SENSITIVITY = 0.002

#@onready var flashlight_beam = $Camera3D/ViewModelContainer/flashlight/FlashLightBeam
#@onready var flashlight_beam = $Camera3D/SubViewportContainer/SubViewport/flashlight/FlashLightBeam
@onready var flashlight_beam = $Camera3D/ViewModelContainer/flashlight/FlashLightBeam
@onready var flashlight_click_sound = $FlashLightClickSound
@onready var use_key_sound = $UseKeySound


# The force of gravity aw
const GRAVITY = -24.8

# This will hold our vertical velocity
var gravity_vec = Vector3.ZERO

# Get a reference to the camera node
@onready var camera = $Camera3D

# --- Functions ---

func _ready():
	# This hides the mouse cursor and keeps it centered in the window
	# so you can look around freely. Press Esc to show it again.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	flashlight_beam.visible = false

func _unhandled_input(event):
	# Escape button triggers cursor to appear again
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# This function captures mouse movement
	if event is InputEventMouseMotion:
		# Rotate the whole player body left/right
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Rotate just the camera up/down
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		# Clamp the camera's rotation so you can't look upside down
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var new_bullet = BULLET_SCENE.instantiate()
		var muzzle_transform = $Camera3D/Muzzle.global_transform
		new_bullet.global_transform = muzzle_transform
		var speed = 30.0
		new_bullet.linear_velocity = -muzzle_transform.basis.z * speed
		get_tree().get_root().add_child(new_bullet)
	if event.is_action_pressed("toggle_flashlight"):
		flashlight_beam.visible = not flashlight_beam.visible
		flashlight_click_sound.play()
	if event.is_action_pressed("interact"):
		use_key_sound.play()

func _physics_process(delta):
	# --- Gravity ---
	# Add gravity every frame if we are not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Movement ---
	# Get input from WASD keys
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Create a direction vector based on where the player is facing
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = SPEED
	if Input.is_action_pressed("sprint"):
		current_speed = SPEED * SPRINT_SPEED
	# Apply movement
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCELERATION * delta)
	else:
		# If no input, slow down (friction)
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		velocity.z = lerp(velocity.z, 0.0, FRICTION * delta)
	# --- Camera Tilt Logic ---
	var target_tilt = 0.0
	var tilt_amount = 0.05#amera tilt in Radians
	var tilt_speed = 5.0   # How fast the camera tilts

	# Get left/right input strength (-1 for left, 1 for right)
	var strafe_input = Input.get_axis("ui_left", "ui_right")
	target_tilt = strafe_input * tilt_amount

	# Smoothly interpolate the camera's tilt (z rotation) towards the target tilt
	camera.rotation.z = lerp(camera.rotation.z, target_tilt, tilt_speed * delta)
	# This function moves the character and handles collisions
	move_and_slide()
