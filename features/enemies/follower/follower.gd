extends CharacterBody3D

@export var target: Node3D
@export var movement_speed: float = 8.0
@export var follow_distance: float = 2.5
@onready var nav_agent = $NavigationAgent3D
func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		velocity = Vector3.ZERO
		move_and_slide()
		return

	nav_agent.target_position = target.global_position


	if nav_agent.is_navigation_finished():

		# If we've arrived, smoothly slow down to a stop.
		velocity = velocity.lerp(Vector3.ZERO, delta * 5.0)
	else:
			var next_point = nav_agent.get_next_path_position()
			var distance_to_target = global_position.distance_to(target.global_position)

			if distance_to_target > follow_distance:
				var direction = (next_point - global_position).normalized()
				velocity = direction * movement_speed
			else:
				velocity = Vector3.ZERO
	move_and_slide()
