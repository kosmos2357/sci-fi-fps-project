class_name AirborneState
extends BaseState

"""
For States that Return is_on_ground() == False
	But are NOT special states like Swimming, Climbing

	ex: JumpState, FallState
"""

# Apply gravity to Player
func process_physics(delta: float) -> void:
	player.velocity.y -= player.gravity * delta
	player.move_and_slide()
