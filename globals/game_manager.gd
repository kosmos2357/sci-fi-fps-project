# GameManager.gd
# This is our global "switchboard" script. It must be set up as an Autoload.
class_name GameManager
extends Node

# --- Properties ---

# This dictionary is our "phonebook" for all named entities in a level.
# The Key will be the entity's name (e.g., "door_01")
# The Value will be a direct reference to the entity's node.
var named_entities = {}


# --- Public API Functions ---

# This is the "registration desk" for our phonebook.
# Any entity that can be targeted (like a door) will call this function on itself
# when the level loads to add itself to the list.
func set_targetname(node_instance: Node, name_string: String):
	if node_instance == null or name_string.is_empty():
		return
	
	named_entities[name_string] = node_instance
	print("GameManager: Registered '", name_string, "'")


# This is the "mail carrier".
# Any entity that can trigger things (like a button) will call this function
# to activate its target.
func use_targets(target_string: String, activator_node: Node):
	if target_string.is_empty():
		return
	
	# This allows for targeting multiple entities by separating names with a comma in TrenchBroom.
	var target_names = target_string.split(",")
	for t_name in target_names:
		var clean_name = t_name.strip_edges() # Removes any accidental spaces
		
		# Check if the target name exists in our phonebook.
		if named_entities.has(clean_name):
			var target_node = named_entities[clean_name]
			
			# As a safety check, make sure the target has a "use" function before we call it.
			if target_node.has_method("use"):
				# This is the magic: call the "use" function on the target node.
				target_node.use(activator_node)
				print("GameManager: '", activator_node.name, "' activated target '", clean_name, "'")
			else:
				print("GameManager Warning: Target '", clean_name, "' has no use() function.")
		else:
			print("GameManager Error: Could not find any registered entity named '", clean_name, "'")

# The dictionary now starts empty! It will be populated at runtime.
var door_locks = {}

# --- NEW REGISTRATION FUNCTION ---
# Doors will call this in their _ready() function to add themselves to our system.
func register_lock(door_name: String, is_locked: bool):
	if door_locks.has(door_name):
		# This door has already been registered, which shouldn't happen.
		# This is a good place to print a warning for debugging.
		print("GameManager Warning: A door named '", door_name, "' tried to register twice.")
		return
	
	# Add the new door to our dictionary with its starting lock state.
	door_locks[door_name] = not is_locked
	print("GameManager: Registered new lock for '", door_name, "' with state: ", is_locked)

# --- This is the new function you will create ---
func unlock_door(door_name: String):
	# First, check if a door with that name actually exists in our database.
	if door_locks.has(door_name):
		# Set its state to 'true' (unlocked).
		door_locks[door_name] = true
		print("GameManager: The lock for '", door_name, "' has been disengaged.")
	else:
		print("GameManager ERROR: Tried to unlock a door that doesn't exist in the lock list: '", door_name, "'")

# You will also need a function for the door to check its own status.
func is_door_unlocked(door_name: String) -> bool:
	if door_locks.has(door_name):
		return door_locks[door_name]
	return false # If it's not in the list, it's considered locked.
	
	
# This is the corrected version of the function
static func id_vec_to_godot_vec(vec: Variant) -> Vector3:
	if vec is String:
		# THIS IS THE CORRECT FUNCTION: split_floats()
		# It takes a string like "0 0 4" and directly returns an array of floats: [0.0, 0.0, 4.0]
		var arr: PackedFloat64Array = vec.split_floats(" ", false)
		
		# Make sure we got exactly 3 numbers
		if arr.size() == 3:
			# Now we can directly create the Vector3 from the float array
			var org_vec = Vector3(arr[0], arr[1], arr[2])
			
			# This is the Quake-to-Godot coordinate swap: (X Y Z) from TB -> (X Z -Y) in Godot
			return Vector3(org_vec.x, org_vec.z, -org_vec.y)
		else:
			# If the format was wrong, return zero to avoid crashing
			return Vector3.ZERO
	
	elif vec is Vector3:
		# If it's already a vector, just do the coordinate swap
		var org_vec = vec
		return Vector3(org_vec.x, org_vec.z, -org_vec.y)

	# If it's neither a String nor a Vector3, return zero as a fallback
	return Vector3.ZERO
