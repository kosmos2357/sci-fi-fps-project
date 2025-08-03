class_name Pushable
extends RigidBody3D

func push(force: Vector3):
	# Apply a purely horizontal force to prevent lifting
	var horizontal_force = force * Vector3(1, 0, 1)
	print("PUSH APPLIED")
	apply_central_force(horizontal_force)
