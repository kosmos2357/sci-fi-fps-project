extends Area3D


var player_is_near: bool

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
