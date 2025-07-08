extends SpotLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
@export var min_light = 0
@export var max_light = 16

#delta not used so added _ to it
func _process(_delta: float):
	light_energy = randf_range(min_light, max_light)


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
