@tool
extends Area3D


var player_is_near: bool
@export var angle: float

func _func_godot_apply_properties(props: Dictionary):
	# Look in terminal Output after building to see wactual state of props recievedww
	print("Raw properties for ", self.name, ": ", props)
	# Base Class Props
	angle = props.get("angle", 1.0)

func _ready():
	# We connect our own signals to our own functions.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true
		# Check for has method
		if body.has_method("enter_climbing_state"):
			body.enter_climbing_state()
			print("Ladder Entered")
func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false
		#check for method
		if body.has_method("exit_climbing_state"):
			body.exit_climbing_state()
			print("Ladder Exited")
