- ```
  ## EXAMPLE VIA TURRET FSM UNSAFE CAUSE RACE CONDITION NULL INSTANCE CAN OCCUR
  States.LOCKED_ON:
      if is_instance_valid(target):
          # ...
          # This is unsafe because get_collider() might be null
          if vision_raycast.get_collider().has_method("take_damage"): 
              vision_raycast.get_collider().take_damage(10)
          else:
              current_state = States.ACQUIRING
  ```
- SOLUTION: is to break up the conditionals and to first ask is_colliding == true
- States.LOCKED_ON:
- ```
  	if is_instance_valid(target):
  		last_known = target.global_position
  		turn_towards(last_known,delta)
  		
  		if vision_raycast.is_colliding():
  			
  			var what_i_hit = vision_raycast.get_collider()
  			
  			if what_i_hit.has_method("take_damage"):
  				what_i_hit.take_damage(10)
  			else:
  				current_state = States.ACQUIRING
  		else:
  			current_state = States.ACQUIRING
  ```
- ```
  # FIX FOR NULL INSTANCES ENCOUNTERED
  if is_instance_valid(what_i_hit) and what_i_hit.has_method("take_damage"):
  						what_i_hit.take_damage(10)
  					else:
  						current_state = States.ACQUIRING
  ```
-
- Again had issue with player head going up during crouch
	- simple collision check in physics proc and input handle in unhandled input was not sufficient
		- Unhandled input can happen in between frames
		- meanwhile phys proc is tied ot frames.
		- Meaning any sort of ray check would get skipped over and simply process unhandled input first
		- Input and physics timeline are separate.