extends CharacterBody3D

# TODO For REFACTOR
"""w
MAJOR COMP
	Swim State
	Crouch State

MINOR COMP
	Flashlight
	Lure
	Shoot
	ViewModel Movement
	Interact

Better Movement Handle
	Screen Tilt

Post Proc
	Death State
	Injure State
"""


# --- Player Properties ---
@export var speed: float = 7.0
@export var acceleration: float = 8.0
@export var friction: float = 10.0
@export var gravity: float =  15.0
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.2

# -- Onready Variables --
@onready var camera = $Camera3D





# --- Local Variables ---
var is_on_ladder
var just_jumped_off_ladder: bool = false




# --- State Machine Setup ---
var states = {
	"idle": IdleState.new(),
	"run": RunState.new(),
	"fall" : FallState.new(),
	"jump" : JumpState.new(),
	"climb" : ClimbState.new(),
}
var current_state


"""
INIT
"""
func _ready():
	for state_name in states:
		states[state_name].player = self

	# Start in the Idle state
	current_state = states["idle"]
	current_state.enter()

	# Hides and locks cursor for FPS Controls
	hide_cursor()



"""
INPUT HANDLE
"""
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		transition_to("jump")
	if event.is_action_pressed("ui_cancel"):
		make_cursor_visible()



func _input(event):
	handle_mouse_movement(event)


"""
PHYSICS PROCESS LOOP
"""
func _physics_process(delta):
	# 1. First, check for transitions
	var input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if not is_on_floor():
		transition_to("fall")
	else:
		if input_vec == Vector2.ZERO:
			transition_to("idle")
		else:
			transition_to("run")

	if is_on_ladder and not just_jumped_off_ladder and current_state != states["climb"]:
		transition_to("climb")
	# 2. Then, run the current state's logic
	if current_state:
		current_state.process_physics(delta)

"""
STATE TRANSITION METHOD
"""
func transition_to(state_name: String):
	if current_state == states[state_name]:
		return

	current_state = states[state_name]
	current_state.enter()

######################################## Handlers
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

######################## Auxillary
# This hides the mouse cursor and keeps it centered in the window
# so you can look around freely. Press Esc to show it again.
func hide_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Escape button triggers cursor to appear again
func make_cursor_visible()-> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
