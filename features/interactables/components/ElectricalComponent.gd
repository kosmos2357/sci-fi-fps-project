"""
Created in an attempt to hide properties inside objects. Didnt work due to
handling of data with func godot.

Works with methods though.
"""
# ElectricalComponent.gd
class_name ElectricalComponent
extends Object

var owner # A reference to the node that owns this component
var is_powered: bool = false


# The constructor must accept the props DICTIONARY
func _init(owner_node, props: Dictionary):
	owner = owner_node

	# ADD THIS LINE to see the data the component receives
	print("ElectricalComponent received props: ", props)

	# Get the 'is_powered' value from inside the dictionary
	is_powered = props.get("is_powered", false)

func power_on():
	if not is_powered:
		is_powered = true
		print(owner.name, " powered ON.")

func power_off():
	if is_powered:
		is_powered = false
		print(owner.name, " powered OFF.")
