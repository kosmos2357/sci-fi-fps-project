extends CharacterBody3D

# TODO For REFACTOR
"""
MAJOR COMP
	Swim State x
	Crouch State x
	# SECTION finished with issues see beloww
MINOR COMP
	Flashlight x
	Lure x
	Shoot x
	ViewModel Movement x
	Interact x

Better Movement Handle
	Screen Tilt x

Post Proc
	Death State
	Injure State (take damage)
"""

# MOUSE BUtton Event SCENES
const LURE_SCENE = preload("res://features/player/lure.tscn")
const BULLET_SCENE = preload("res://features/player/scenes/bullet.tscn")
# --- Player Properties ---
@export var speed: float = 7.0
@export var acceleration: float = 8.0
@export var friction: float = 10.0
@export var gravity: float =  15.0
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.2

@export var sprint_speed: float = speed * 2.0


# Underwater movement properties
@export var water_speed = 2.5
@export var water_gravity = 5.0 # Lower gravity simulates buoyancy
@export var swim_speed = 2.0   # How fast you move up/down


# -- Onready Variables --
@onready var camera = $Camera3D

@onready var flashlight_beam = $Camera3D/ViewModelContainer/flashlight/FlashLightBeam

# --- Crouching Properties ---
@export var crouch_speed = 3.0
var wants_to_crouch: bool = false
var is_actually_crouching: bool = false
var stand_height: float = 2.0
var crouch_height: float = 1.0


@onready var collision_shape = $CollisionShape3D
@onready var head_check_raycast = $CollisionShape3D/HeadCheck

# NOTE
# Create Reference to our SoundComponent Node since we
# are working directly with the node itself this time.
# As opposed to working with the OOP Hiearchy we are
# Workign with the node Hiearchy.
# Hence Node Composition
@onready var sound_component = $SoundComponent
@onready var animation_component = $AnimationComponent
# --- Crouching Properties ---


# --- Local Variables ---
var is_on_ladder
var is_underwater
var just_jumped_off_ladder: bool = false
var is_sprinting: bool = false


# --- State Machine Setup ---
var states = {
	"idle": IdleState.new(),
	"run": RunState.new(),
	"fall" : FallState.new(),
	"jump" : JumpState.new(),
	"climb" : ClimbState.new(),
	"swim" : SwimState.new(),
}
var current_state


"""
INIT
"""
func _ready():
	# For each state
	# Get our state object and access the .player var inside our state object
	# and set it a reference to the player.gd (this) script
	# obj.var = self
	for state_name in states:
		states[state_name].player = self
		states[state_name].sound_component = sound_component
		states[state_name].animation_component = animation_component
	# Start in the Idle state
	current_state = states["idle"]
	current_state.enter()

	# Hides and locks cursor for FPS Controls
	hide_cursor()




"""
INPUT HANDLE
"""
func _unhandled_input(event: InputEvent) -> void:
	# To jump one must press and be on the floor
	if event.is_action_pressed("jump") and is_on_floor():
		transition_to("jump")
	if event.is_action_pressed("ui_cancel"):
		make_cursor_visible()
	elif event.is_action_pressed("toggle_flashlight"):
		toggle_flashlight()
	elif event.is_action_pressed("interact"):
		toggle_use_key()
	# LEFT MOUSE BUTTON Event
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		handle_mouse_button(event)
	# RIGHT MOUSE BUTTON Event
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		handle_lure()


func _input(event):
	handle_mouse_movement(event)
	is_sprinting = Input.is_action_pressed("sprint")

	if event.is_action_pressed("crouch"):
		wants_to_crouch = true
	elif event.is_action_released("crouch"):
		wants_to_crouch = false



"""
PHYSICS PROCESS LOOP
"""
func _physics_process(delta):

	#_handle_crouching()

	if current_state:
		current_state.process_physics(delta)

	# --- Check for state transitions in order of priority ---

	# Priority 1: Climbing. If this is true, we ignore everything else.
	if is_on_ladder and not just_jumped_off_ladder:
		transition_to("climb")

	# Priority 2: Swimming. This only runs if we are NOT on a ladder.
	elif is_underwater:
		transition_to("swim")

	# Priority 3: Airborne. This only runs if we are NOT on a ladder and NOT in water.
	elif not is_on_floor():
		transition_to("fall")

	# Priority 4: Grounded. This is the default case if none of the above are true.
	else:
		var input_vec = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
		if input_vec == Vector2.ZERO:
			transition_to("idle")
		else:
			transition_to("run")
"""
STATE TRANSITION METHOD
"""
func transition_to(state_name: String):
	if current_state == states[state_name]:
		return

	current_state = states[state_name]
	current_state.enter()

######################################## Handlers
# WARNING BUG
"""
clamp isnt working when moving left and right
"""
func handle_mouse_movement(event) -> void:
		if event is InputEventMouseMotion:
			# Rotate the whole player body left and right
			self.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			# Rotate the camera up and down
			camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			# Clamp the camera's vertical rotation to prevent it from flipping over
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

######################################## HELPER FUNCTIONS
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


# NOTE
# WARNING BUG The modified logic for camera reorientation is causing a bug with the muzzle
# This logic should be replaced due to to messign with camera orientationww
"""
A couple of issue wtih this implementation that the old version didn't have
	1. crouch jumping doesnt work. Player collides now with platforms that are harder to jump over
	2. players head clips through ceiling if jumping in vent
	3.Auto crouch feature is janky
	4. Players head goes clip through surface touching players head
	5. need to verify player eye position since this modifies its state
"""
func _handle_crouching():
	# --- This part is the same ---
	var can_stand_up = not head_check_raycast.is_colliding()

	if wants_to_crouch:
		is_actually_crouching = true
	else:
		if can_stand_up:
			is_actually_crouching = false
		else:
			is_actually_crouching = true

	# --- This is the new part ---
	# Define our target heights and positions
	var target_shape_height = crouch_height if is_actually_crouching else stand_height

	# The shape's Y position should always be half its current height.
	# This keeps its "feet" on the ground (at y=0).
	var target_shape_pos_y = target_shape_height / 2.0

	# The camera's Y position should be near the top of the capsule.
	# Let's say eye-level is at 80% of the character's height.
	#NOTE
	"""
	The bug can be fixed by simply removing the manual movement of eye height
	not sure why needed?
	"""
	var standing_cam_pos_y = stand_height * 0.734
	var crouching_cam_pos_y = crouch_height # When crouching, camera might be closer to the top of the shape
	var target_cam_pos_y = crouching_cam_pos_y if is_actually_crouching else standing_cam_pos_y

	# Smoothly interpolate to the target values
	var interp_speed = 10.0 * get_physics_process_delta_time()
	collision_shape.shape.height = lerp(collision_shape.shape.height, target_shape_height, interp_speed)
	collision_shape.position.y = lerp(collision_shape.position.y, target_shape_pos_y, interp_speed)
	camera.position.y = lerp(camera.position.y, target_cam_pos_y, interp_speed)

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


func toggle_flashlight() -> void:
	flashlight_beam.visible = not flashlight_beam.visible
	sound_component.play_sound("flashlight_key")

func toggle_use_key() -> void:
	sound_component.play_sound("useKeySound")


func handle_lure() -> void:
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

func handle_mouse_button(event):
	var new_bullet = BULLET_SCENE.instantiate()
	var muzzle_transform = $Camera3D/Muzzle.global_transform
	var speed = 30.0
	new_bullet.global_transform = muzzle_transform
	new_bullet.linear_velocity = -muzzle_transform.basis.z * speed
	get_tree().get_root().add_child(new_bullet)
######################## Auxillary
# This hides the mouse cursor and keeps it centered in the window
# so you can look around freely. Press Esc to show it again.
func hide_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Escape button triggers cursor to appear again
func make_cursor_visible()-> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
