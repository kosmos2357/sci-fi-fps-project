# The simplified AnimationComponent.gd
class_name AnimationComponent
extends Node

# Get Reference to parent Player node
@onready var player: CharacterBody3D = get_parent()

# Viewmodel node here
@export var viewmodel: Node3D

# Sway properties
@export_group("Viewmodel Animation")
@export var sway_speed: float = 4.0
@export var sway_amount: float = 0.05
@export var sway_lerp_speed: float = 1.0 # Increased for a better feel

var viewmodel_origin: Vector3
var sway_t: float = 0.0

func _ready():
	if is_instance_valid(viewmodel):
		viewmodel_origin = viewmodel.position

# This is now the main function called by the player
func update_viewmodel_sway(delta):
	if not is_instance_valid(viewmodel): return

	var horizontal_velocity = player.velocity * Vector3(1, 0, 1)
	var sway_offset: Vector3 = Vector3.ZERO

	if horizontal_velocity.length() > 0.1 and player.is_on_floor():
		sway_t += delta * sway_speed
		sway_offset.z = cos(sway_t) * sway_amount
		sway_offset.y = abs(sin(sway_t)) * sway_amount * -1.0 # Simplified the sine wave
	else:
		sway_t = 0 # Reset timer when not moving

	var target_position = viewmodel_origin + sway_offset
	viewmodel.position = viewmodel.position.lerp(target_position, delta * sway_lerp_speed)
