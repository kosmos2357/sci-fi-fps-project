# Terminal.gd
extends Area3D

# Drag your TerminalUI.tscn file here in the Inspector
@export var terminal_ui_scene: PackedScene
# This is the 'target' that the terminal will affect
@export var target_name: String = ""

var ui_instance = null
var player_is_near: bool = false
enum States { BOOTING, ACTIVE, EXITING }
var current_state: States

var log_entries = [
	{
		"title": "Maintenance Report #7-A",
		"content": "Coolant leak in sector 3 continues to be a problem. Recommend full system flush. Also, someone keeps stealing my sandwiches from the break room fridge."
	},
	{
		"title": "Personal Log: Dr. Aris",
		"content": "The anomaly shows signs of... awareness. My requests for a research transfer have been denied. I will have to proceed on my own."
	},
	{
		"title": "SECURITY ALERT: CONTAINMENT BREACH",
		"content": "[DATA CORRUPTED]"
	}
]

var BOOT_LOGO: String = """
*****************************************************
					.   .xXXXX+.   .
			   .   ..   xXXXX+.-   ..   .
		 .   ..  ... ..xXXXX+. --.. ...  ..   .
	 .   ..  ... .....xXXXX+.  -.-..... ...  ..   .
   .   ..  ... ......xXXXX+.  . .--...... ...  ..   .
  .   ..  ... ......xXXXX+.    -.- -...... ...  ..   .
 .   ..  ... ......xXXXX+.   .-+-.-.-...... ...  ..   .
 .   ..  ... .....xXXXX+. . --xx+.-.--..... ...  ..   .
.   ..  ... .....xXXXX+. - .-xxxx+- .-- .... ...  ..   .
 .   ..  ... ...xXXXX+.  -.-xxxxxx+ .---... ...  ..   .
 .   ..  ... ..xXXXX+. .---..xxxxxx+-..--.. ...  ..   .
  .   ..  ... xXXXX+. . --....xxxxxx+  -.- ...  ..   .
   .   ..  ..xXXXX+. . .-......xxxxxx+-. --..  ..   .
	 .   .. xXXXXXXXXXXXXXXXXXXXxxxxxx+. .-- ..   .
		 . xXXXXXXXXXXXXXXXXXXXXXxxxxxx+.  -- .
		   xxxxxxxxxxxxxxxxxxxxxxxxxxxxx+.--
			xxxxxxxxxxxxxxxxxxxxxxxxxxxxx+-
*****************************************************
*  This system is for the use of authorized users   *
*  only. Usage of  this system may be monitored     *
*  and recorded                                     *
*****************************************************
"""


func _ready():
	# Connect to our own signals to detect the player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event):
	# If the UI is already open, stop this function immediately.
	if is_instance_valid(ui_instance):
		return
	# Check if the player is near and presses the 'interact' key
	if player_is_near and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled() # Prevents other inputs from firing
		_open_terminal()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false

func _open_terminal():
	if is_instance_valid(ui_instance): return

	# --- Start the Boot Sequence ---
	current_state = States.BOOTING

	ui_instance = terminal_ui_scene.instantiate()
	get_tree().get_root().add_child(ui_instance)

	var output_label = ui_instance.find_child("OutputLabel")


	# Disable the input field during boot-up
	get_tree().paused = true

	var sanitized_logo = BOOT_LOGO.replace("\t", "    ")
	# --- The "Animation" ---
	output_label.text = "*** LO-FI-SCI-FI LTM ***"
	await get_tree().create_timer(2.0).timeout
	output_label.text = "Initializing connection..."
	await get_tree().create_timer(1.0).timeout
	output_label.append_text(sanitized_logo)
	await get_tree().create_timer(0.5).timeout
	output_label.append_text("\nSystem Online.")
	await get_tree().create_timer(0.5).timeout
	output_label.append_text("\nWelcome. Type 'help' or 'exit'.")

	var input_line = ui_instance.find_child("InputLine")

	# --- Boot-up Complete ---
	# Now, switch to the ACTIVE state and enable input
	current_state = States.ACTIVE
	input_line.editable = true
	input_line.grab_focus()
	input_line.text_submitted.connect(_on_command_entered)

	# Disable player controls
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.set_controls_enabled(false)

func _on_command_entered(command: String):
	# Only process commands if we are in the ACTIVE state
	if current_state != States.ACTIVE:
		return
	var output_label = ui_instance.find_child("OutputLabel")
	var input_line = ui_instance.find_child("InputLine")

	output_label.append_text("\n> " + command)
	input_line.clear()

	# Parse the command
	var parts = command.strip_edges().split(" ")
	match parts[0].to_lower():
		"unlock":
			if not target_name.is_empty():
				# We can use our GameManager to send the message
				GAME.send_message(target_name, "unlock")
				output_label.append_text("\n...Signal sent to unlock " + target_name)
		"exit":
			_close_terminal()
		"help":
			output_label.append_text("\n** COMMANDS **")
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\nHELP")
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\nPRINT")
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\nLOGS")
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\n*** END ****")
			await get_tree().create_timer(1.0).timeout
		"print":
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\n")
			var command_filtered = command.substr(5)
			output_label.append_text(command_filtered)
			output_label.append_text("\n*** END ****")
		"logs":
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\n")
			output_label.append_text("\n [AVAILABLE LOGS]")
			output_label.append_text("\n ----------------------------------------------")
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\n [1] Bay 01 Report ")
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\n [2] Bay 02 Report ")
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\n*** END ****")
			await get_tree().create_timer(1.0).timeout
		_:
			output_label.append_text("\nError: Unknown command.")

func _close_terminal():
	# Prevent logic from running a second time. Only enters once.
	if is_instance_valid(ui_instance) and current_state != States.EXITING:
		current_state = States.EXITING
		# Setup UI elements
		var output_label = ui_instance.find_child("OutputLabel")

		output_label.append_text("\n...Connection terminated.")
		await get_tree().create_timer(1.0).timeout
		# Process of freeing instance and re-enable controls
		ui_instance.queue_free()
		ui_instance = null
		# Re-enable player controls
		var player = get_tree().get_first_node_in_group("player")
		if is_instance_valid(player):
			player.set_controls_enabled(true)
		# Unpause the game
		get_tree().paused = false
