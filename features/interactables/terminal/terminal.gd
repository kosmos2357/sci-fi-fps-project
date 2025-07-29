@tool
extends Area3D
"""
Terminal Entity
"""
var player_is_near:bool = false
@export var door_name:String = ""

func _func_godot_apply_properties(props: Dictionary):
	door_name = props.get("door_name", "")

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("player is near")
		player_is_near = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false

func  get_door_name():
	return self.door_name

func _input(event: InputEvent) -> void:
	if player_is_near and event.is_action_pressed("interact"):
		print("Terminal IN Use: ", get_door_name())
		GAME.unlock_door(get_door_name())
