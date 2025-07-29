class_name IdleState
extends GroundedState

func process_physics(delta):
	#print("Entering IDLE state")
	player.velocity.x = lerp(player.velocity.x, 0.0, player.friction * delta)
	player.velocity.z = lerp(player.velocity.z, 0.0, player.friction * delta)
	#player.handle_camera_tilt(delta)
	player.move_and_slide()
