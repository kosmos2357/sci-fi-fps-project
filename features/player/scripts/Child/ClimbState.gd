class_name ClimbState
extends SpecialState

#NOTE
"""
Issues
Push off feature has side effect of when on top acting as trampoline player cannot move in FALL state so continuously go
up and down on top of ladder
"""
func process_physics(delta):
	print("Entering CLIMB State")

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")

	# Check for jumping OFF the ladder
	if Input.is_action_just_pressed("jump"):
		player.transition_to("fall")
				# --- ADD THIS LOGIC ---
		# 1. Set the flag on the player
		player.just_jumped_off_ladder = true

		# NOTE: Look at this later...
		# 2. Create a one-shot timer to resetwww the flag after 0.5 seconds
		player.get_tree().create_timer(0.5).timeout.connect(
			func():
				player.just_jumped_off_ladder = false
		)
		# --- END OF ADDED LOGIC ---
		# Apply a push directly AWAY from where the player is looking, plus a little hop up.
		var push_direction = player.global_transform.basis.z
		player.velocity = push_direction * (player.speed * 0.75) + (Vector3.UP * (player.jump_velocity * 0.5))
		return

	# Handle movement ON the ladder
	# Vertical movement (W/S)
	var vertical_velocity = Vector3.UP * input_dir.y * player.speed

	# Horizontal (strafe) movement (A/D)
	var horizontal_velocity = player.transform.basis * Vector3(input_dir.x, 0, 0) * player.speed

	# Combine and apply velocities
	player.velocity = vertical_velocity + horizontal_velocity
	player.move_and_slide()
