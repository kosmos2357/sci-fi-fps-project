"""
Created in an attempt to hide properties inside objects. Didnt work due to
handling of data with func godot.

Works with methods though.
"""
class_name BaseComponent
extends Object
var owner # Reference to node that owns this component
var is_enabled: bool = false

func _init(owner_node, starts_enabled: bool) -> void:
	is_enabled = starts_enabled
	owner = owner_node

func enable():
	if not is_enabled:
		is_enabled = true
		print(owner.name, " enabled.")

func disable():
	if is_enabled:
		is_enabled = false
		print(owner.name, " disabled.")
