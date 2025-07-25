class_name RunState
extends GroundedState

func process_physics(delta):
	print("Entering RUN State")
	var input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (player.transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()

	# Use our is_Sprinting flag to trigger which to use for current_speed
	var current_speed = player.sprint_speed if player.is_sprinting else player.speed

	if player.is_actually_crouching:
		current_speed = player.crouch_speed

	# DEBUG
	if player.is_sprinting:
		print("Flag Sprint in RUN State")
	# DEBUG
	player.velocity.x = lerp(player.velocity.x, direction.x * current_speed, player.acceleration * delta)
	player.velocity.z = lerp(player.velocity.z, direction.z * current_speed, player.acceleration * delta)

	#player.handle_camera_tilt(delta)

	if animation_component:
		animation_component.play_animation("sway", delta)
	player.move_and_slide()
