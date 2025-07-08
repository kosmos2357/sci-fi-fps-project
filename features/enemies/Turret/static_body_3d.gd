extends StaticBody3D

# --- Turret Components ---
@onready var pivot = $Pivot
@onready var head = $Pivot/Head
@onready var vision_raycast = $Pivot/Head/VisionRayCast

# --- Turret Properties ---
@export var rotation_speed = 1.0
@export var fire_rate = 1.0 # Shots per second
var fire_cooldown = 0.0

# --- AI State ---
enum { IDLE, TARGETING, FIRING }
var current_state = IDLE
var player_ref = null # A reference to the player node

# We'll use an Area3D to detect when the player is nearby.
@onready var detection_area = $DetectionArea

func _ready():
	# Connect the Area3D's signals to our script
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

func _physics_process(delta):
	# This is our State Machine. We check the current state and act accordingly.
	match current_state:
		IDLE:
			# Do nothing, or slowly rotate back and forth.
			pass
		TARGETING:
			# If we have a reference to the player, turn to face them.
			if is_instance_valid(player_ref):
				# Turn the pivot (Y-axis) and head (X-axis) towards the player
				var target_direction = player_ref.global_position - pivot.global_position
				#turn_towards(target_direction, delta)

				# Check if we have a clear line of sight
				vision_raycast.target_position = to_local(player_ref.global_position)
				vision_raycast.force_raycast_update()
				if vision_raycast.is_colliding() and vision_raycast.get_collider() == player_ref:
					# If we have a clear shot, switch to FIRING state
					current_state = FIRING
		
		FIRING:
			# If we lose sight of the player or they leave the area, go back to TARGETING
			if not is_instance_valid(player_ref) or not vision_raycast.get_collider() == player_ref:
				current_state = TARGETING
				return

			# Continue to track the player
			var target_direction = player_ref.global_position - pivot.global_position
			#turn_towards(target_direction, delta)

			# Handle shooting cooldown
			if fire_cooldown > 0:
				fire_cooldown -= delta
			else:
				# If cooldown is over, fire!
				fire()
				# Reset cooldown
				fire_cooldown = 1.0 / fire_rate

func turn_towards(direction: Vector3, delta: float):
	# This function smoothly rotates the turret head towards the target direction
	var target_transform = head.global_transform.looking_at(head.global_position + direction)
	head.global_transform = head.global_transform.lerp(target_transform, rotation_speed * delta)


func fire():
	print(self.name, " is firing!")
	# This is where you would instance your bullet scene, similar to the player's script
	# var bullet = BulletScene.instantiate()
	# var muzzle = $Pivot/Head/Muzzle
	# get_tree().get_root().add_child(bullet)
	# bullet.global_transform = muzzle.global_transform
	# bullet.linear_velocity = -muzzle.global_transform.basis.z * bullet_speed

# --- Signal Callbacks ---
func _on_player_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		current_state = TARGETING # Start targeting when player gets close

func _on_player_exited(body):
	if body == player_ref:
		player_ref = null
		current_state = IDLE # Go back to idle when player leaves
