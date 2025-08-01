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


# Called by a trigger (like a button) to send a message to a target.
func send_message(target_name: String, message: String):
	if not named_entities.has(target_name):
		print("GameManager Error: Could not find target '", target_name, "'")
		return

	var target_node = named_entities[target_name]

	# Use dynamic dispatch to call the method that matches the message string
	if target_node.has_method(message):
		target_node.call(message)
	else:
		print("GameManager Warning: Target '", target_name, "' has no method named '", message, "'")
