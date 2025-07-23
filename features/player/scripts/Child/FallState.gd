class_name FallState
extends AirborneState

func process_physics(delta: float) -> void:
	super.process_physics(delta)
	print("Entering FALL State")
