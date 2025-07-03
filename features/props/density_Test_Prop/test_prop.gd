extends Node3D



func _ready():
	# Instead of running the code now, we tell the engine:
	# "Please call my 'setup' function when you're done with the current frame."
	call_deferred("setup")

func setup():
	# This code now runs safely, after the node is fully settled in the tree.
	print("My position in the world is: ", global_transform.origin)
