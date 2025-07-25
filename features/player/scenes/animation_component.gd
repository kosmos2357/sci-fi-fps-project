class_name AnimationComponent
extends Node


# We store a reference to apply_sway(delta) through Callable()
# That way we can use our apply_sway functionality as a value tied to our key
#
@onready var animation_player = {
	"sway": Callable(self, "apply_sway"),
}

# Get Reference to parent Player node
@onready var player: CharacterBody3D = get_parent()

# Viewmodel node here
@export var viewmodel: Node3D


# Sway properties
@export_group("Viewmodel Animation")
@export var sway_speed: float = 4.0
@export var sway_amount: float = 0.05
@export var sway_lerp_speed: float = 1.0

# This will store the viewmodel's resting position
var viewmodel_origin: Vector3
# This is our timer for the sine/cosine waves
var sway_t: float = 0.0

func _ready():
	# If a viewmodel is assigned, store its initial position as the origin.
	if is_instance_valid(viewmodel):
		viewmodel_origin = viewmodel.position

func apply_sway(delta):
	if not is_instance_valid(viewmodel): return

	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	var sway_offset: Vector3 = Vector3.ZERO

	# Check if the player is on the floor and movingw.
	if horizontal_velocity.length() > 0.1:
		sway_t += delta * sway_speed
		sway_offset.z = cos(sway_t) * sway_amount
		sway_offset.y = sin(sway_t * 2) * sway_amount
	else:
		# If we are standing still, reset the sway timer
		sway_t = 0

	# The target position is the original resting position plus the sway offset.
	var target_position = viewmodel_origin + sway_offset

	# Smoothly move the viewmodel towards its target position.
	viewmodel.position = viewmodel.position.lerp(target_position, delta * sway_lerp_speed)

# New thing here is the play animation
# Accomplished through finding the value which in this case is
# apply_sway and .call
func play_animation(animation_name: String, delta: float):
	if animation_player.has(animation_name):
		#Play Animation
		animation_player[animation_name].call(delta)
