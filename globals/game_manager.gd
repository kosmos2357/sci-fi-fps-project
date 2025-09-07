class_name GameManager
extends Node

signal entity_activated(activator_name, targetted_entities, message)

# The "phone book" of all registered entities
var named_entities = {}
var event_history: Array = []
# Called by entities in their _ready() function to add themselves to the book.
func register_entity(node_instance: Node, name_string: String):
	if node_instance == null or name_string.is_empty():
		return

	named_entities[name_string] = node_instance
	print("GameManager: Registered '", name_string, "'")


# This function can now handle one or many targets
# TODO: Add args to signal emission for event bus, as well make args an array if possible
# WARNING: Adding args breaks all other entities, need to somehow make optional.
func send_message(target_string: String, message: String, activator: Node, args: Array = []):
	if target_string.is_empty():
		return

	var target_names = target_string.split(",")
	var message_sent_successfully = false

	for t_name in target_names:
		var clean_name = t_name.strip_edges()
		if named_entities.has(clean_name):
			var target_node = named_entities[clean_name]
			if target_node.has_method(message):
				# If the 'args' array is empty, use the simple .call()
				if args.is_empty():
					target_node.call(message)
					message_sent_successfully = true
				# If the 'args' array has items, use .callv() to pass them along
				else:
					target_node.callv(message, args)
					message_sent_successfully = true



	# Event Bus
	# After the loop, if the message was successful, make the public announcement
	if message_sent_successfully and is_instance_valid(activator) and "targetname" in activator:
		var activator_name = activator.targetname
		# Broadcast the ACTIVATOR'S name
		emit_signal("entity_activated", activator_name, target_string,  message)
		_log_event(activator_name, target_string, message)

func _log_event(activator_name: String, target_string: String, message: String):
	var log_entry = {
		"timestamp": Time.get_ticks_msec(),
		"activator": activator_name,
		"target": target_string,
		"message": message
	}
	event_history.append(log_entry)
	# You can print this for live debugging
	print("EVENT LOGGED: ", log_entry)

func get_history() -> Array:
	return event_history
