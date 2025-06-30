# In bullet.gd
extends RigidBody3D

# This function is called once when the bullet is created.
func _ready():
	# Set a timer to delete the bullet after 3 seconds.
	await get_tree().create_timer(3.0).timeout
	queue_free() # Deletes the bullet node.
