class_name JumpState
extends AirborneState

func enter():
	print("Entering JUMP State")
	#sound_component.play_sound("jumpsound")
	player.velocity.y = player.jump_velocity
