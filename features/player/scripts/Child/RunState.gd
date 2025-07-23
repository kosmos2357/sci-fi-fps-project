class_name RunState
extends GroundedState

func process_physics(delta):
	print("Entering RUN State")
	var input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (player.transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()

	player.velocity.x = lerp(player.velocity.x, direction.x * player.speed, player.acceleration * delta)
	player.velocity.z = lerp(player.velocity.z, direction.z * player.speed, player.acceleration * delta)

	player.move_and_slide()
