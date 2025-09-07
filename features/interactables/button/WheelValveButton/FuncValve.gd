extends Area3D

var player_is_near: bool = false
@onready var animatable_body = $AnimatableBody3D
@export var rotation_speed: float = 2.0
@export var target = "monitor_a"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if player_is_near and Input.is_action_pressed("interact"):
		animatable_body.rotate_y(rotation_speed * delta)
		# 2. Calculate the rotation as a percentage (0 to 100)
		var current_angle = fmod(rad_to_deg(animatable_body.rotation.y), 360)
		if current_angle < 0: current_angle += 360
		var percentage = (current_angle / 360.0) * 100.0

		print("Percentage: ", percentage)
		# 3. Send the percentage to the display via the GameManager
		if not target.is_empty():
			GAME.send_message(target, "set_percentage", self, [percentage])

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_is_near = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_is_near = false
