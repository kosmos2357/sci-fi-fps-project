class_name GameManager
extends Node

# The "phone book" of all registered entities
var named_entities = {}

# Called by entities in their _ready() function to add themselves to the book.
func register_entity(node_instance: Node, name_string: String):
	if node_instance == null or name_string.is_empty():
		return

	named_entities[name_string] = node_instance
	print("GameManager: Registered '", name_string, "'")


# This function can now handle one or many targets
func send_message(target_string: String, message: String):
	if target_string.is_empty():
		return

	# --- THIS IS THE NEW LOGIC ---
	# Split the target string into an array of names
	var target_names = target_string.split(",")

	# Loop through each name in the array
	for t_name in target_names:
		# It's good practice to trim whitespace in case of "name_a, name_b"
		var clean_name = t_name.strip_edges()

		# --- The rest of the logic is the same, but inside the loop ---
		if not named_entities.has(clean_name):
			print("GameManager Error: Could not find target '", clean_name, "'")
			continue # Continue to the next name in the list

		var target_node = named_entities[clean_name]

		if target_node.has_method(message):
			target_node.call(message)
		else:
			print("GameManager Warning: Target '", clean_name, "' has no method named '", message, "'")
