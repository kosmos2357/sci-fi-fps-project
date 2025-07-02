# High Level Summary
- ## Code Overview (Type Overview)
- Split into 3 engine callbacks (Note _ signifies engine callback)
- _ready(), _unhandled_input(event), _physics_process(delta)
- Godot has several Built in methods/classes/objects that are designed to be used with this feature in mind
	- Class: Input
		- Method: set_mouse_mode, is_action_just_pressed, get_vector, get_axis
		- CONSTANT: MOUSE_MODE_CAPTURED, MOUSE_MODE_VISIBLE, MOUSE_SENSITIVITY,
	- Class: InputEventMouseMotion
	- Class: Node3D
		- Method: rotate_y, rotate_x
		- Property: Rotation
	- Class: InputEventMouseButton
- if event is.......... Pattern rather than if event ==
	- `is` tests whether a variable extends a given class, or is of a given built-in type.
-
- ## Functional Overview
- ### Mouse Input
	- ```
	  
	  # Capture Mouse Motion
	  if event is InputEventMouseMotion:
	  		# Rotate player body left and right
	  		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
	  		# Rotate only camera up and down
	  		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
	  		# Clamp the camera's rotation so you can't look upside down
	  		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	  ```
- ### Keyboard Input
-
-