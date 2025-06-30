@tool
extends Area3D

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if player_is_near and event.is_action_pressed("interact"):
		print("TERMINAL USED")
		print(self.door_name)
		GAME.unlock_door(self.door_name)
		
