# In PulseManager.gd
extends Node

# The signal now broadcasts the total elapsed time
signal pulse_updated(total_time)

var total_time: float = 0.0
@export var pulse_speed: float = 1.0

func _process(delta):
	total_time += delta
	# Emit the raw time value
	emit_signal("pulse_updated", total_time)
