extends CharacterBody3D
"""
This script requires Bullet path to be preset here!
"""
const BULLET_SCENE = preload("res://features/player/scenes/bullet.tscn")

const GRAVITY = -24.8

@export var speed = 7.0
@export var sprint_speed = 2
@export var jump_velocity = 7.0
@export var friction = 10
@export var acceleration = 12
@export var mouse_sensitivity = 0.002

@onready var flashlight_beam = $Camera3D/ViewModelContainer/flashlight/FlashLightBeam
@onready var flashlight_click_sound = $FlashLightClickSound
@onready var use_key_sound = $UseKeySound
@onready var camera = $Camera3D
@onready var flash_light_model = $Camera3D/ViewModelContainer/flashlight

# This will hold our vertical velocity
var gravity_vec = Vector3.ZERO

"""
Procedures for Unhandled Input
"""

# This hides the mouse cursor and keeps it centered in the window
# so you can look around freely. Press Esc to show it again.
func hide_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Starting State of Flash Light visibility
func flash_light_beam_init(value: bool) -> void:
	flashlight_beam.visible = value

func toggle_flashlight() -> void:
	flashlight_beam.visible = not flashlight_beam.visible
	flashlight_click_sound.play()
	
func toggle_use_key() -> void:
	use_key_sound.play()

# Escape button triggers cursor to appear again
func make_cursor_visible()-> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Handle Mouse Motion
func handle_mouse_motion(event):
		# Mouse Motion
		if event is InputEventMouseMotion:
			# Rotate the whole player body left/right
			rotate_y(-event.relative.x * mouse_sensitivity)
			# Rotate just the camera up/down
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			# Clamp the camera's rotation so you can't look upside down
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

# Handle Mouse Button Press
func handle_mouse_button(event):
	var new_bullet = BULLET_SCENE.instantiate()
	var muzzle_transform = $Camera3D/Muzzle.global_transform
	var speed = 30.0
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		new_bullet.global_transform = muzzle_transform
		new_bullet.linear_velocity = -muzzle_transform.basis.z * speed
		get_tree().get_root().add_child(new_bullet)
		

"""
READY
"""
func _ready():
	hide_cursor()
	flash_light_beam_init(false)
"""
UNHANDLED INPUT
"""
func _unhandled_input(event):
	# Handle Our Mouse Events
	handle_mouse_motion(event)
	handle_mouse_button(event)
	# Handle our Key press Events
	if event.is_action_pressed("ui_cancel"):
		make_cursor_visible()
	elif event.is_action_pressed("toggle_flashlight"):
		toggle_flashlight()
	elif event.is_action_pressed("interact"):
		toggle_use_key()

"""
PHYSICS PROCESS
"""

"""
Procedures for Physics Process
"""

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

# --- Camera Tilt Logic ---
func handle_camera_tilt(delta) -> void:
	var target_tilt = 0.0
	var tilt_amount = 0.05 #camera tilt in Radians
	var tilt_speed = 5.0   # How fast the camera tilts
	# Get left/right input strength (-1 for left, 1 for right)
	var strafe_input = Input.get_axis("ui_left", "ui_right")
	target_tilt = strafe_input * tilt_amount
	# Smoothly interpolate the camera's tilt (z rotation) towards the target tilt
	camera.rotation.z = lerp(camera.rotation.z, target_tilt, tilt_speed * delta)
	
func handle_sprint() -> int:
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	else:
		return 1


func _physics_process(delta):
	# NOTE Y Axis Vector
	# Add gravity every frame if we are not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	handle_jump()
	# NOTE X and Z Axis Vectors
	# Get input from WASD keys
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Create a direction vector based on where the player is facing
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = speed
	# Apply movement
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed * handle_sprint(), acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed * handle_sprint(), acceleration * delta)
	else:
		# If no input, slow down (friction)
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.z = lerp(velocity.z, 0.0, friction * delta)
	
	handle_camera_tilt(delta)
	move_and_slide()
