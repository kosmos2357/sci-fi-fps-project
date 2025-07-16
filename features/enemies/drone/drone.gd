extends CharacterBody3D
# In your Drone's script (e.g., drone.gd)

@export var patrol_path: NodePath
@export var movement_speed = 5.0

@export var fire_rate = 5.0
var path_follow: PathFollow3D
@onready var nav_agent = $pivot/NavigationAgent3D
@onready var detection_area = $pivot/DetectionArea
@onready var detector = $pivot/Detector
@onready var pivot = $pivot
@onready var barrel = $pivot/Barrel

# How fast the drone moves along the path
var patrol_speed = 5.0
var cooldown: float
enum States {IDLE, PATROL, ALERT, PURSUE, FIRE, LURED}
var current_state = States.IDLE
var target = null
var scan_speed = 2.0

var lure_target_position: Vector3
var lure_timeout = 5.0 # Drone will be lured for 5 seconds
var current_lure_time = 0.0



func lure_to_position(lure_pos: Vector3):
	print(name, " has been lured to ", lure_pos)
	lure_target_position = lure_pos
	current_lure_time = lure_timeout # Reset the timer
	current_state = States.LURED
	# We set target to null so it stops chasing the player
	target = null
	

func _ready():
	# Get the PathFollow3D node from the path you assign in the Inspector
	if not patrol_path.is_empty():
		path_follow = get_node(patrol_path).get_node("PathFollow3D")
	
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

func _physics_process(delta):
	if cooldown > 0:
			cooldown = cooldown - delta
	match current_state:
		States.IDLE:
			current_state = States.PATROL
		States.PATROL:
			if path_follow != null:
				follow_path(delta)
		States.ALERT:
			if is_instance_valid(target):
				detector.rotate_y(scan_speed * delta)
				if path_follow != null:
					follow_path(delta)
					if detector.is_colliding():
						if detector.get_collider() == target:
							current_state = States.PURSUE
						else:
							current_state = States.ALERT
					else:
						current_state = States.ALERT
				
					
		States.PURSUE:
			"""
			Known issue: Move and Face angles are to be handled separate. 
			"""
			# GET Player Location
			# FACE player
			# Move to player
			# if barrel Ray is t then states.fire else States.pursue 
			# else States.idle
			if is_instance_valid(target):
				print("I AM PURSUING")
				look_at(target.global_position, Vector3.UP)
				
				var next_point = nav_agent.get_next_path_position()
				var direction = (next_point - global_position).normalized()
				nav_agent.target_position = target.global_position
				# Face player
				# Move TO
				velocity = direction * movement_speed
				move_and_slide()
				
				if barrel.is_colliding():
					
					var what_i_hit = barrel.get_collider()
					if is_instance_valid(what_i_hit) and what_i_hit.has_method("take_damage"):
						current_state = States.FIRE
					else:
						current_state = States.PURSUE
				else: 
					current_state = States.PURSUE
				
		States.FIRE:
			if is_instance_valid(target):
				if cooldown <= 0:
					cooldown = 1/fire_rate
					print("FIRING")
					target.take_damage(1)
					current_state = States.PURSUE
				else:
					current_state = States.PURSUE
		States.LURED:
			# First, check if the lure has expired. This is our only exit condition.
			current_lure_time -= delta
			if current_lure_time <= 0:
				print(name, " lure has expired. Returning to patrol.")
				current_state = States.IDLE
				return # Exit this state
			
			# If the timer is still active, figure out if we need to move or wait.
			var distance_to_lure = global_position.distance_to(lure_target_position)
			
			if distance_to_lure > 1.5: # If we are far from the lure...
				# ...move towards it.
				nav_agent.target_position = lure_target_position
				var next_point = nav_agent.get_next_path_position()
				var direction = (next_point - global_position).normalized()
				velocity = direction * movement_speed
			else: # If we have arrived at the lure...
				# ...stop moving and just wait here.
				velocity = Vector3.ZERO
			
			move_and_slide()


func follow_path(delta) -> void:
	path_follow.progress += patrol_speed * delta
	# Tell the NavigationAgent to move towards the helper's position
	nav_agent.target_position = path_follow.global_position
	# The rest of your existing navigation logic works perfectly from here
	var next_path_point = nav_agent.get_next_path_position()
	var direction = (next_path_point - global_position).normalized()
	
	velocity = direction * movement_speed
				
	move_and_slide()
# --- Signal Callbacks ---
func _on_player_entered(body):
		# ADD THIS LINE: If we are lured, ignore the player completely.
	if current_state == States.LURED:
		return
	if body.is_in_group("player"):
		print("Target entering range. Acquiring...")
		target = body
		#last_known = body.global_position
		current_state = States.ALERT
		

func _on_player_exited(body):
	if body == target:
		print("Target left range. Returning to Idle.")
		target = null
		current_state = States.IDLE
