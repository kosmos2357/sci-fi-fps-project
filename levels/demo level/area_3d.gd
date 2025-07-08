extends Area3D

var player_is_near:bool = false
@onready var sound = $Warning
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("player is near")
		player_is_near = true
		sound.play()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false
