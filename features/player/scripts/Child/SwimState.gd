class_name SwimState

extends SpecialState

func process_physics(delta):
	print("Entering SWIM State")

	# Water gravity?
	if not player.is_on_floor():
		player.velocity.y = player.water_gravity * delta - 1
		print(player.velocity)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Create a direction vector based on where the player is facing
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# --- Underwater Movement ---
	player.velocity.x = direction.x * player.water_speed
	player.velocity.z = direction.z * player.water_speed

	# Vertical swimming controls override gravity effects
	if Input.is_action_pressed("jump"):
		player.velocity.y = player.swim_speed # Swim upw
	elif Input.is_action_pressed("crouch"):
		player.velocity.y = -player.swim_speed # Swim down
	# If not swimming, buoyancy (low gravity) takes over
	player.move_and_slide()
