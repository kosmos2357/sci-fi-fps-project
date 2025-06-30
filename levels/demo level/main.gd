# In level_logic.gd
extends Node3D

@export var button_to_connect: Node
@export var door_to_open: Node

# In level_logic.gd, below your variables

func _ready():
	# A safety check to make sure you assigned both nodes in the Inspector
	if button_to_connect and door_to_open:

		# This is the connection!
		# When the button emits its "pressed" signal...
		# ...call the "use" function on the door.
		button_to_connect.pressed.connect(door_to_open.use)

		print("SUCCESS: Button is now wired to the door.")
	else:
		print("ERROR: Please drag the button and door nodes into the Inspector slots.")
