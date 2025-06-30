# In ButtonLogic.gd
@tool
extends Area3D # Or whatever your button's root node is.

@export var target: String = ""
var player_is_near = false

func _func_godot_apply_properties(props: Dictionary):
	target = props.get("target", "")

# You will need to connect your Area3D's body_entered/exited signals to these functions.
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false

func _input(event):
	if player_is_near and event.is_action_pressed("interact"):
		print("Button pressed! Telling GAME to activate target: '", target, "'")
		if not target.is_empty():
			GAME.use_targets(target, self)
