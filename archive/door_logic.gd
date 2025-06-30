@tool
extends AnimatableBody3D

# These variables are already being set correctly by the importer. Perfect.
@export var targetname: String = ""
@export var message: String = ""

func _func_godot_apply_properties(props: Dictionary):
	targetname = props.get("targetname", "")
	message = props.get("message", "Default from importer")

func _ready():
	if Engine.is_editor_hint(): return
	if not targetname.is_empty():
		GAME.set_targetname(self, targetname)

func use(activator):
	# This part is already working and printing your message.
	print("--- DOOR SCRIPT ACTIVATED ---")
	print("The secret message is: '", message, "'")
	print("---------------------------")
	
	# ADD THIS ONE LINE TO MAKE THE DOOR DISAPPEAR:
	queue_free()
