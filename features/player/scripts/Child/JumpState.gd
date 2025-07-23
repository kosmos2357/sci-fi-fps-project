class_name JumpState
extends AirborneState

func enter():
	print("Entering JUMP State")
	player.velocity.y = player.jump_velocity
