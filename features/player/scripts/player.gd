# WARNING WARNING WARNING
"""
NOTE
Old Pre-Refactor player.gd script
No longer in use

New version moved to playerFSM.gd
"""
# WARNING WARNING WARNING

extends CharacterBody3D
"""
This script requires Bullet path to be preset here!
"""
const LURE_SCENE = preload("res://lure.tscn")
const BULLET_SCENE = preload("res://features/player/scenes/bullet.tscn")

const GRAVITY = -24.8

@export var speed = 7.0
@export var sprint_speed = 2
@export var jump_velocity = 7.0
@export var friction = 10
@export var acceleration = 12
@export var mouse_sensitivity = 0.002
@export var health = 100
@export var crouch_depth: float = -0.3 #Note: Anything higher results in head going through plane surface.Need to check racast height to match crouch depth.
@export var crouch_speed: float = 0.2
@export_group("Viewmodel Animation")
@export var sway_speed: float = 4.0
@export var sway_amount: float = 0.05


@onready var camera_y_position = get_viewport().get_camera_3d().global_position.y
@onready var flashlight_beam = $Camera3D/ViewModelContainer/flashlight/FlashLightBeam
@onready var flashlight_click_sound = $FlashLightClickSound
@onready var use_key_sound = $UseKeySound
@onready var camera = $Camera3D
@onready var flash_light_model = $Camera3D/ViewModelContainer/flashlight
@onready var collision_shape = $CollisionShape3D
@onready var head_check = $CollisionShape3D/HeadCheck
@onready var viewmodel_container = $Camera3D/ViewModelContainer
# This will hold our vertical velocity
var gravity_vec = Vector3.ZERO
var is_on_ladder: bool = false
var is_crouching: bool = false
var standing_camera_y: float
var standing_collision_height: float
var standing_collision_y: float

# This flag is the player's INTENT. It's set by the input function.
var wants_to_crouch: bool = false

# This is the player's ACTUAL state. It's only ever changed by the physics function.
var is_actually_crouching: bool = false

# Continuous timer for sway
var sway_t: float = 0.0

var viewmodel_origin: Vector3

var is_underwater: bool

var current_state

#### NOTE: 3.5 Refactor
"""
Turn player.gd into a statemanager.
player.gd simply reads input and assigns appropriate state.gd file to be executed.
Also have state dictionary with key : pair

"STATE" : state.new()
"""

"""
State Dictionary
KEY: VALUEw

( < "state" : State.new() > -> State.gd -> classname State )

"""
# NOTE: commented out until needed because of init loop
var state_dict = {
	"run" : RunState.new(),
	"jump" : JumpState.new(),
	#"sprint" : SprintState.new(),
	#"crouch" : CrouchState.new(),
	"climb" : ClimbState.new(),
	#"swim" : SwimState.new(),
	"idle" : IdleState.new(),
	"fall" : FallState.new(),
}




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

	# REFACTOR: INIT idle state
	current_state = state_dict["idle"]
	current_state.enter()

	# Refactor: Initialize our states to avoid having to current_state = enter(self) every time
	for state_name in state_dict:
		state_dict[state_name].player = self

	hide_cursor()
	flash_light_beam_init(false)
	standing_camera_y = camera.position.y
	standing_collision_height = collision_shape.shape.height
	standing_collision_y = collision_shape.position.y

	#Save viewmodel pos
	if is_instance_valid(viewmodel_container):
		viewmodel_origin = viewmodel_container.position


func is_head_collding() -> bool:
	if head_check.is_colliding():
		print("COLLIDING")
		return true
	else:
		return false
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
	if event.is_action("crouch"):
			# If the crouch key is pressed or released, update our intent flag.
			wants_to_crouch = event.is_pressed()
			print("--- INPUT: Crouch key state changed! wants_to_crouch is now: ", wants_to_crouch)
	# Check for a right mouse click to place the lure
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		# Get the raycast node
		var raycast = $Camera3D/RayCast3D # Use the correct path to your raycast

		# Check if the raycast is hitting a surface
		if raycast.is_colliding():
			# Get the point where the ray hit
			var collision_point = raycast.get_collision_point()

			# Create an instance of the Lure scene
			var lure_instance = LURE_SCENE.instantiate()

			# Add the lure to the main world tree
			get_tree().get_root().add_child(lure_instance)

			# Position the lure where the raycast hit
			lure_instance.global_position = collision_point

	if event.is_action_pressed("jump") and is_on_floor():
		transition_to("jump")



func set_crouch_state(crouching: bool):
	is_crouching = crouching

	# Determine our target heights based on the new state.
	var target_cam_y = standing_camera_y + crouch_depth if is_crouching else standing_camera_y
	var target_col_height = standing_collision_height / 2.0 if is_crouching else standing_collision_height
	var target_col_y = standing_collision_y / 2.0 if is_crouching else standing_collision_y

	# Create a tween to smoothly animate everything at once.
	var tween = create_tween()
	tween.set_parallel(true) # Makes all animations run at the same time.

	# Animate the camera's Y position.
	tween.tween_property(camera, "position:y", target_cam_y, crouch_speed).set_trans(Tween.TRANS_SINE)
	# Animate the collision shape's height.
	tween.tween_property(collision_shape.shape, "height", target_col_height, crouch_speed).set_trans(Tween.TRANS_SINE)
	# Animate the collision shape's Y position to keep its base on the ground.
	tween.tween_property(collision_shape, "position:y", target_col_y, crouch_speed).set_trans(Tween.TRANS_SINE)

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


func take_damage(amt :int):
	health = health - amt
	print("Player has taken: ", amt, " damage")
	create_damage_flash()
	if health <= 0:
		die()
		print("PLAYER HAS DIED!")


func create_damage_flash():
	# 1. Create the ColorRect node.
	var flash_rect = ColorRect.new()

	# 2. Set its properties.
	# We start with a semi-transparent red color.
	flash_rect.color = Color(1.0, 0.0, 0.0, 0.4)
	# Make it fill the entire screen.
	flash_rect.size = get_viewport().get_visible_rect().size

	# 3. Add it to a new CanvasLayer so it draws on top of everything.
	var canvas = CanvasLayer.new()
	canvas.add_child(flash_rect)
	add_child(canvas)

	# 4. Create the fade-out animation.
	# We will tween its 'modulate' property, which controls its overall color and transparency.
	var tween = create_tween()

	# Animate the modulate property from its current color (red) to fully transparent red
	# over a short duration (e.g., 0.4 seconds).
	tween.tween_property(flash_rect, "modulate", Color(1.0, 0.0, 0.0, 0.0), 0.4)

	# 5. Clean up after the animation is finished.
	# Once the tween is complete, we wait for its 'finished' signal.
	await tween.finished
	# After it finishes, we delete the entire CanvasLayer and its contents.
	canvas.queue_free()

func die():
	print("PLAYER HAS DIED.")

	# To prevent the dead player from moving, we disable their physics.
	set_physics_process(false)

	# --- Create a Fade-to-Black Effect ---
	# 1. Create a black rectangle.
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0) # Start fully transparent.
	fade_rect.size = get_viewport().get_visible_rect().size

	# 2. Add it to a CanvasLayer so it draws on top of everything.
	var canvas = CanvasLayer.new()
	canvas.add_child(fade_rect)
	add_child(canvas)

	# 3. Animate its color from transparent to opaque black.
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color.BLACK, 1.0) # Fade over 1 second

	# 4. Wait for the fade to finish.
	await tween.finished

	# 5. Go to the Game Over screen.
	get_tree().change_scene_to_file("res://levels/demo level/main.tscn")

#
#func handle_normal_movement(delta) -> void:
	## NOTE Y Axis Vector
	## Add gravity every frame if we are not on the flwoor
	#if not is_on_floor():
		#current_state = state_dict["fall"]
	##handle_jump()
	## NOTE X and Z Axis Vectors
	## Get input from WASD keys
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	## Create a direction vector based on where the player is facing
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#var current_speed = speed
	## Apply movement
	#if direction:
		#velocity.x = lerp(velocity.x, direction.x * current_speed * handle_sprint(), acceleration * delta)
		#velocity.z = lerp(velocity.z, direction.z * current_speed * handle_sprint(), acceleration * delta)
		#
	#else:
		## If no input, slow down (friction)
		#velocity.x = lerp(velocity.x, 0.0, friction * delta)
		#velocity.z = lerp(velocity.z, 0.0, friction * delta)
	#
	#handle_camera_tilt(delta)
	#move_and_slide()
	#
func handle_ladder_movement(delta) -> void:

	velocity.y -= water_gravity * delta
		# When on a ladder, we have different physics.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	if Input.is_action_just_pressed("jump"):
		exit_climbing_state()
		velocity = -global_transform.basis.z * (speed * 0.75) + (Vector3.UP * (jump_velocity * 0.5))
		return

	# W/S keys now control vertical movement (Y-axis).
	velocity.y = input_dir.y * speed * handle_sprint()

	# A/D keys can still control horizontal movement.
	var direction = transform.basis * Vector3(input_dir.x, 0, 0)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

"""
PHYSICS PROCESS
"""

# Underwater movement properties
@export var water_speed = 2.5
@export var water_gravity = 5.0 # Lower gravity simulates buoyancy
@export var swim_speed = 2.0   # How fast you move up/down

func handle_underwater_movement(delta):
	print("I AM IN SWIM STATE")
	# Water gravity?
	if not is_on_floor():
		# NOTE: equation vel.y -= water_grav * delta seems to not do much here
		# Simply setting vel.y = water_grav * delta does produce the sinking effect
		# with the constant on the end creating a downwards pull or sinking effect
		velocity.y = water_gravity * delta - 1
		print(velocity)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Create a direction vector based on where the player is facing
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# --- Underwater Movement ---
	velocity.x = direction.x * water_speed
	velocity.z = direction.z * water_speed

	# Vertical swimming controls override gravity effects
	if Input.is_action_pressed("jump"):
		velocity.y = swim_speed # Swim up
	elif Input.is_action_pressed("crouch"):
		velocity.y = -swim_speed # Swim down
	# If not swimming, buoyancy (low gravity) takes over


func _physics_process(delta):

	if is_on_floor() and current_state != state_dict["idle"]:
		print("Idle")
		transition_to("idle")

	if is_on_ladder and current_state != state_dict["climb"]:
		#handle_ladder_movement(delta)
		#current_state.process_physics(delta)
		transition_to("climb")

	else:
		#Handle Normal Movement
		#handle_normal_movement(delta)
		transition_to("run")
	if current_state:
		current_state.process_physics(delta)

	if is_underwater:
		handle_underwater_movement(delta)


# This is the check for standing up.
	# We check if the player WANTS to stand (wants_to_crouch is false)
	# AND if they ARE currently crouching (is_actually_crouching is true).
	if not wants_to_crouch and is_actually_crouching:
		print("PHYSICS: Player wants to stand. Checking for obstacles...")

		# We check the raycast here, in the safety of the physics step.
		if head_check.is_colliding():
			print("PHYSICS: Obstacle detected! Cannot stand up. Staying crouched.")
		else:
			print("PHYSICS: Path is clear! Standing up now.")
			is_actually_crouching = false

			set_crouch_state(false)

	# This is the check for crouching down.
	# We check if the player WANTS to crouch AND if they are NOT already crouching.
	elif wants_to_crouch and not is_actually_crouching:
		print("PHYSICS: Player wants to crouch. Crouching now.")
		is_actually_crouching = true

		set_crouch_state(true)

	# --- NEW, CORRECTED SWAY LOGIC ---
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	# This will hold the sway offset for the current frame.
	var sway_offset: Vector3 = Vector3.ZERO

	# Check if the player is on the floor and moving.
	if horizontal_velocity.length() > 0.1:
		# If we are walking, increase our "sway timer".
		sway_t += delta * sway_speed

		# Calculate the sway offset using sine and cosine waves.
		sway_offset.z = cos(sway_t) * sway_amount
		sway_offset.y = sin(sway_t * 2) * sway_amount

	# THE FIX: We calculate the final target position by adding the sway offset
	# to the original resting position. When standing still, sway_offset is (0,0,0),
	# so the target is just the original position.
	var target_position = viewmodel_origin + sway_offset

	# Smoothly move the viewmodel container towards its final target position.
	viewmodel_container.position = viewmodel_container.position.lerp(target_position, delta)

func enter_climbing_state():
	is_on_ladder = true
	print("I am on a ladder")

func exit_climbing_state():
	is_on_ladder = false
	print("I am on not on a ladder")

func enter_swim_state():
	is_underwater = true
	print("I am swimming")

func exit_swim_state():
	is_underwater = false
	print("I am not swimming")

# REFACTOR: Transistion helper function
func transition_to(state_name: String):
	# Don't transition if we're already in that state
	if current_state == state_dict[state_name]:
		return

	# Call the exit function on the old state, if it exists
	if current_state and current_state.has_method("exit"):
		current_state.exit()

	# Switch to the new state
	current_state = state_dict[state_name]

		# --- ADD THIS LOGIC ---
	# Leaving the ClimbState
	if current_state == state_dict["jump"]:
		print("LEAVIG CLIMBSTATE")
		is_on_ladder = false

	# Entering the ClimbState
	if state_dict[state_name] == state_dict["climb"]:
		print("ENTERING CLIMB STATE")
		is_on_ladder = true
	# --- END OF ADDED LOGIC ---


	# Call the enter function on the new state, if it exists
	if current_state.has_method("enter"):
		current_state.enter()


# WARNING WARNING WARNING
"""
NOTE
Old Pre-Refactor player.gd script
No longer in use
New version moved to playerFSM.gd
"""
# WARNING WARNING WARNING
