## player_new.gd
#extends CharacterBody3D
#
##=============================================================================
## 1. STATES
##=============================================================================
#enum States { IDLE, RUN, FALL, JUMP, CLIMB, SWIM }
#var current_state: States = States.IDLE
#
## The dictionary only holds the complex state objects
#var complex_states = {
	#"climb": ClimbState.new(),
	#"swim": SwimState.new()
#}
#
##=============================================================================
## 2. EXPORTED PROPERTIES
##=============================================================================
#@export_group("Movement")
#@export var speed: float = 7.0
#@export var acceleration: float = 8.0
#@export var friction: float = 10.0
#@export var jump_velocity: float = 5.0
#@export var gravity: float = 15.0
#@export var sprint_speed: float = speed * 2.0
#@export_group("Special Movement")
#@export var climb_speed: float = 3.0
#@export var water_speed: float = 4.0
#@export var swim_speed = 2.0   # How fast you move up/down
#@export var water_gravity: float = 4.0
#@export var flash_light_sound: SoundEvent
#@export var use_key_sound: SoundEvent
## --- Crouching Properties ---
#@onready var head_check_raycast = $CollisionShape3D/HeadCheck
#@onready var collision_shape = $CollisionShape3D
#@onready var camera = $Head/SpringArm3D/Camera3D
#@export var crouch_speed = 3.0
#var wants_to_crouch: bool = false
#var is_actually_crouching: bool = false
#var stand_height: float = 2.0
#var crouch_height: float = 1.0
#
	## Grab Features -----
## The maximum distance the object can be from the hold position before being dropped
#@export var drop_distance: float = 3.0
	## Grab Features ---
#@onready var grab_raycast = $Head/SpringArm3D/Camera3D/GrabCast
#@onready var hold_position = $Head/SpringArm3D/Camera3D/GrabPlacement
	## Grab Feature reference
#var held_object = null
	##Push Feature
#@onready var push_raycast = $Head/SpringArm3D/Camera3D/pushCast
#@export var push_strength: float = 8.0 # Force needs to be a larger number
#
#
#@export_group("Mouse")
#@export var mouse_sensitivity: float = 0.2
##=============================================================================
## 3. INTERNAL VARIABLES & NODE REFERENCES
##=============================================================================
## Flags for checking conditions
#var is_on_ladder: bool = false
#var is_underwater: bool = false
#var just_jumped_off_ladder: bool = false
#
## We will store the desired rotation here instead of reading from the node
#var camera_pitch: float = 0.0
#var camera_roll: float = 0.0
#
##used for tracking previous state for fixing ladder trampoline
#var previous_state = null
#var next_state = current_state
#var is_sprinting: bool = false
## Component references
#@onready var head = $Head
#@onready var flashlight_beam = $Head/SpringArm3D/Camera3D/ViewModelContainer/flashlight/FlashLightBeam
## ... (add other components like SoundManager, etc.)
#
##=============================================================================
## 4. ENGINE CALLBACKS
##=============================================================================
#func _ready():
	#hide_cursor()
	## Initialize the complex states
	#for state_name in complex_states:
		#complex_states[state_name].player = self
#
#
#
	## ... (your other ready logic like capturing the mouse)
#
#func _unhandled_input(event):
	#if event.is_action_pressed("ui_cancel"):
		#make_cursor_visible()
	## Handle one-shot actions that trigger a state change
	#if event.is_action_pressed("jump") and is_on_floor():
		#self.velocity.y = jump_velocity + 1
		#print("Velocity_y", self.velocity.y)
		#current_state = States.FALL # Immediately enter the falling state after a jump
	#elif event.is_action_pressed("toggle_flashlight"):
		#toggle_flashlight()
	#elif event.is_action_pressed("interact"):
		#toggle_use_key()
#
#func _input(event: InputEvent) -> void:
	#handle_mouse_movement(event)
	#is_sprinting = Input.is_action_pressed("sprint")
	#if event.is_action_pressed("crouch"):
		#wants_to_crouch = true
	#elif event.is_action_released("crouch"):
		#wants_to_crouch = false
	## Grab Feature
	#elif event.is_action_pressed("interact"):
		#if held_object:
			#print("Drop Object")
			#_drop_object()
		#else:
			#print("Grab Object")
			#_grab_object()
#func _physics_process(delta):
	#print("CURRENT_STATE ", current_state)
	#print("PREVIOUS_STATE", previous_state)
	## --- "THINK" PHASE: Determine the correct state for this frame ---
	#var input_vec = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
#
	#_handle_push_grab(delta)
	#_handle_crouching()
	#if is_on_ladder and not just_jumped_off_ladder:
#
		#current_state = States.CLIMB
	#elif is_underwater:
		#current_state = States.SWIM
	#elif not is_on_floor():
#
		#current_state = States.FALL
	#else: # Must be on the ground
		#if input_vec == Vector2.ZERO:
			#current_state = States.IDLE
		#else:
			#current_state = States.RUN
#
#
#
		## --- THIS IS WHERE THE FORWARD HOP LOGIC GOES ---
		#if current_state == States.FALL and previous_state == States.CLIMB:
			## Apply the special forward hop velocity
			#var push_direction = -global_transform.basis.z
			#velocity = push_direction * (speed * 0.75) + (Vector3.UP * (jump_velocity * 0.5))
#
	## --- "ACT" PHASE: Execute the logic for the current state ---
	#match current_state:
		#States.IDLE:
			#_state_idle(delta)
		#States.RUN:
			#_state_run(delta)
		#States.FALL:
			#_state_fall(delta)
		#States.CLIMB:
			#complex_states["climb"].process_physics(delta)
		#States.SWIM:
			#complex_states["swim"].process_physics(delta)
	#handle_camera_tilt(delta)
	#move_and_slide()
#
##=============================================================================
## 5. STATE LOGIC FUNCTIONS
##=============================================================================
#func _state_idle(delta):
	#velocity.x = lerp(velocity.x, 0.0, friction * delta)
	#velocity.z = lerp(velocity.z, 0.0, friction * delta)
#
#func _state_fall(delta):
	#print("Enter Fall State")
	#velocity.y -= gravity * delta
	#if previous_state == States.CLIMB:
		#print("My previous state was climb")
		#velocity.z = 1.5
		#velocity.y = 5.0
		#previous_state = null
#
#func _state_run(delta):
	#var input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
#
	## Use our is_Sprinting flag to trigger whicwh to use for current_speed
	#var current_speed = sprint_speed if is_sprinting else speed
#
	##if is_actually_crouching:
	##	current_speed = crouch_speed
#
	## DEBUG
	#if is_sprinting:
		#print("Flag Sprint in RUN State")
	## DEBUG
	#velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration * delta)
	#velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration * delta)
#
#
#
	##if animation_component:
	##	animation_component.play_animation("sway", delta)
#
#
##=============================================================================
## 6. HANDLER FUNCTIONS
##=============================================================================
#func handle_mouse_movement(event) -> void:
	#if event is InputEventMouseMotion:
		## Use mouse X to rotate the player body left and right
		#self.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
#
		## Instead of rotating the head directly, we just update our pitch variable
		#camera_pitch += -event.relative.y * mouse_sensitivity
#
		## Clamp the pitch variable
		#camera_pitch = clamp(camera_pitch, -90, 90)
#
## --- Camera Tilt Logic ---
#func handle_camera_tilt(delta) -> void:
	## --- Camera Tilt Logic ---
	#var target_tilt = 0.0
	#var tilt_amount = 3.0  # Increased for a more visible effect, in degrees
	#var tilt_speed = 5.0
#
	#var strafe_input = Input.get_axis("ui_left", "ui_right")
	#target_tilt = strafe_input * tilt_amount
#
	## Smoothly interpolate our roll variable
	#camera_roll = lerp(camera_roll, target_tilt, tilt_speed * delta)
#
	## Apply the final, combined rotation from our variables
	#head.rotation_degrees = Vector3(camera_pitch, 0, camera_roll)
#
#
#
#func _handle_crouching():
	### --- This part is the same ---
	##var can_stand_up = not head_check_raycast.is_colliding()
##
	##if wants_to_crouch:
		##is_actually_crouching = true
	##else:
		##if can_stand_up:
			##is_actually_crouching = false
		##else:
			##is_actually_crouching = true
##
	### --- This is the new part ---
	### Define our target heights and positions
	##var target_shape_height = crouch_height if is_actually_crouching else stand_height
##
	### The shape's Y position should always be half its current height.
	### This keeps its "feet" on the ground (at y=0).
	##var target_shape_pos_y = target_shape_height / 2.0
##
	### The camera's Y position should be near the top of the capsule.
	### Let's say eye-level is at 80% of the character's height.
	###NOTE
	##"""
	##The bug can be fixed by simply removing the manual movement of eye height
	##not sure why needed?
	##"""
	##var standing_cam_pos_y = stand_height * 0.734
	##var crouching_cam_pos_y = crouch_height # When crouching, camera might be closer to the top of the shape
	##var target_cam_pos_y = crouching_cam_pos_y if is_actually_crouching else standing_cam_pos_y
#
	### Smoothly interpolate to the target values
	##var interp_speed = 10.0 * get_physics_process_delta_time()
	##collision_shape.shape.height = lerp(collision_shape.shape.height, target_shape_height, interp_speed)
	##collision_shape.position.y = lerp(collision_shape.position.y, target_shape_pos_y, interp_speed)
	##camera.position.y = lerp(camera.position.y, target_cam_pos_y, interp_speed)
#
	#pass
#
#
#
#func _handle_push_grab(delta):
	## --- PUSHING LOGIC ---
	#if push_raycast.is_colliding():
		#var collider = push_raycast.get_collider()
		#if collider and collider.has_method("push"):
			## Use our velocity to determine the direction and strength of the push
			#collider.push(self.velocity * push_strength)
#
	#if is_instance_valid(held_object):
		## Grab Feature
		## Check the distance between the object and its ideal hold position
		#var distance = held_object.global_position.distance_to(hold_position.global_position)
#
		## If it's too far (stuck on a wall), drop it.
		#if distance > drop_distance:
			#_drop_object()
		#else:
			## If it's close enough, continue carrying it.
			#var move_direction = hold_position.global_position - held_object.global_position
			#held_object.move_and_collide(move_direction * 20.0 * delta)
#
#func _grab_object():
	## Check if the raycast is hitting a physics body
	#if grab_raycast.is_colliding():
		#var collider = grab_raycast.get_collider()
		## Check if the object is in the "grabbable" group
		#if collider and collider.is_in_group("grabbable"):
			#held_object = collider
			#held_object.gravity_scale = 0.0
#
#func _drop_object():
	#if not is_instance_valid(held_object):
		#return
#
	## Re-enable the object's physics
	#held_object.gravity_scale = 1.0
#
	## Give it a little push forward based on the camera's direction
	#var push_direction = -head.global_transform.basis.z
	#held_object.apply_central_impulse(push_direction * 1.0)
#
	## Clear our reference to the object
	#held_object = null
#
##=============================================================================
## 6. TOGGLE FUNCTIONS
##=============================================================================
#
#func toggle_flashlight() -> void:
	#flashlight_beam.visible = not flashlight_beam.visible
	#SoundManager.play_sound_event(flash_light_sound, self.global_position)
#
#func toggle_use_key() -> void:
	#SoundManager.play_sound_event(use_key_sound, self.global_position)
#
##=============================================================================
## 6. STATE FUNCTIONS
##=============================================================================
#func enter_climbing_state():
	#is_on_ladder = true
	#print("I am on a ladder")
#
#func exit_climbing_state():
	#is_on_ladder = false
	#print("I am on not on a ladder")
#
#func enter_swim_state():
	#is_underwater = true
	#print("I am swimming")
#
#func exit_swim_state():
	#is_underwater = false
	#print("I am not swimming")
#
##=============================================================================
## 7. AUX FUNCTIONS
##=============================================================================
#func hide_cursor() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#
## Escape button triggers cursor to appear again
#func make_cursor_visible()-> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
