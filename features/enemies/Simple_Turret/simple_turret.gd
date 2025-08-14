# In simple_turret.gd
extends StaticBody3D

@onready var pivot = $Pivot
@onready var detection_area = $DetectionArea
@onready var vision_raycast = $Pivot/VisionRayCast
@onready var cheat_ray = $Pivot/CheatRay
@export var rotation_speed: float = 5.0
@export var fire_rate: float = 1.0
# --- The new State Machine ---
enum States { IDLE, ACQUIRING, LOCKED_ON, FIRING }
var current_state = States.IDLE

var target = null # This will hold a reference to the player node.

func _ready():
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

var last_known: Vector3
var cooldown: float
func _physics_process(delta):
	if cooldown > 0:
		cooldown = cooldown - delta
	# Our state machine checks which state we are in and acts accordingly.
	match current_state:

		States.IDLE:
			# Do nothing while idle.
			pass
		States.ACQUIRING:
			# If we have a target, turn towards it.
			if is_instance_valid(target):
				if is_in_open(target.global_position):
					turn_towards(target.global_position, delta)
					if vision_raycast.is_colliding() and vision_raycast.get_collider() == target:
						# If the raycast hit something AND that thing was our target...
						current_state = States.LOCKED_ON
				else:
					current_state = States.ACQUIRING
			else:
				current_state = States.ACQUIRING

		States.LOCKED_ON:
			# If we have a target, keep tracking it.

			if is_instance_valid(target):
				last_known = target.global_position
				turn_towards(last_known,delta)

				if vision_raycast.is_colliding():

					var what_i_hit = vision_raycast.get_collider()

					if cooldown <= 0:
						if is_instance_valid(what_i_hit) and what_i_hit.has_method("take_damage"):
							cooldown = 1/fire_rate
							$Gun_Sound.play()
							what_i_hit.take_damage(10)
						else:
							current_state = States.ACQUIRING
				else:
					current_state = States.ACQUIRING



func is_in_open(target_global):
	cheat_ray.look_at(target_global)
	if cheat_ray.is_colliding() and cheat_ray.get_collider() == target:
		return true
	else:
		return false
func turn_towards(target_pos: Vector3, delta: float):

	var direction = (target_pos - pivot.global_position)

	var target_basis = Basis.looking_at(direction)

	pivot.global_basis = pivot.global_basis.slerp(target_basis, rotation_speed * delta)

# --- Signal Callbacks ---
func _on_player_entered(body):
	if body.is_in_group("player"):
		print("Target entering range. Acquiring...")
		target = body
		last_known = body.global_position
		current_state = States.ACQUIRING

func _on_player_exited(body):
	if body == target:
		print("Target left range. Returning to Idle.")
		target = null
		current_state = States.IDLE
