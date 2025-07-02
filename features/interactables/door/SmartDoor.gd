@tool
extends AnimatableBody3D


@export var targetname: String = ""
@export var move_offset: Vector3 = Vector3.ZERO
@export var speed: float = 1.0
@export var starts_locked: bool = true 
@export var name_id: String = ""
# --- Internal state variables ---
var is_open: bool = false
var start_position: Vector3
var end_position: Vector3

# This receives the data from TrenchBroom. We know this part works.
func _func_godot_apply_properties(props: Dictionary):
	targetname = props.get("targetname", "")
	speed = props.get("speed", 1.0)
	move_offset = props.get("move_offset", Vector3.ZERO) # We get the Vector3 directly
	name_id = props.get("name_id", "")
	starts_locked = props.get("starts_locked", true) 
	
# This runs when the game starts, using the SAVED @export variables.
func _ready():
	if Engine.is_editor_hint(): return
	
	# Register with the GameManager so it can be triggered.
	if not targetname.is_empty() and GameManager:
		GAME.set_targetname(self, targetname)
	# Instead of registering its targetname, it now registers its lock state.
	if not name_id.is_empty() and GameManager:
		GAME.register_lock(name_id, starts_locked)
	# Calculate the start and end positions.
	start_position = global_position
	end_position = start_position + move_offset

# This function is called by a button or a direct interaction.
func use(activator):
	# STEP 1: Check for permission first.
	# We ask the GameManager if this specific door is unlocked.
	# Note: I'm assuming the variable is named 'door_id', change it if yours is different.
	if not GAME.is_door_unlocked(self.name_id):
		return # This exits the function immediately.

	# STEP 2: If we passed the check, proceed with normal open/close logic.
	# The code below will ONLY run if the door is unlocked.
	is_open = not is_open # Flip the state (open -> close or close -> open)

	var destination
	if is_open:
		# If we are now open, our destination is the end position.
		destination = end_position
	else:
		# If we are now closed, our destination is the start position.
		destination = start_position
		
	# Create and run the smooth movement animation.
	var tween = create_tween()
	tween.tween_property(self, "global_position", destination, speed).set_trans(Tween.TRANS_SINE)
