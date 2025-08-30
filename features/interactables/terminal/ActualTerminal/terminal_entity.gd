# Terminal.gd
extends Area3D

# CONST
const DEFAULT_DELAY_TIME = 1.0

# Drag your TerminalUI.tscn file here in the Inspector
@export var terminal_ui_scene: PackedScene
# This is the 'target' that the terminal will affect
@export var target_name: String = "door_b"
var correct_password: String = "4LPHA"
var ui_instance = null
var player_is_near: bool = false
enum States { BOOTING, ACTIVE, EXITING }
var current_state: States
var is_waiting_for_password: bool = false
@onready var startup_sound = $AudioStreamPlayer
@onready var beep_sound = $AudioStreamPlayer2
@onready var done_sound = $AudioStreamPlayer3
@onready var error_sound = $AudioStreamPlayer4
@export var log_entries = [
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
	},
	{
		"title": "Personal Log: Dr. Aris",
		"content": "The anomaly shows signs of... awareness. My requests for a research transfer have been denied. I will have to proceed on my own."
	},
	{
		"title": "Personal Log: Dr. Aris",
		"content": "The anomaly shows signs of... awareness. My requests for a research transfer have been denied. I will have to proceed on my own."
	},

]

@export var BOOT_LOGO: String = """
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
	startup_sound.play()
	ui_instance = terminal_ui_scene.instantiate()
	get_tree().get_root().add_child(ui_instance)

	var output_label = ui_instance.find_child("OutputLabel")


	# Disable the input field during boot-up
	get_tree().paused = true

	var sanitized_logo = BOOT_LOGO.replace("\t", "    ")
	# --- The "Animation" ---
	await write_line(output_label, "*** LO-FI-SCI-FI LTM ***")
	await write_line(output_label, "\n*** Initializing System ***")
	await write_line(output_label, sanitized_logo, 0.5)
	await write_line(output_label, "\n*** SYSTEM ONLINE ***", 0.5)
	await write_line(output_label, "\nWelcome. Type 'help' or 'exit'.")
	done_sound.play()
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

	output_label.scroll_following = false
	output_label.scroll_following = true

func _on_command_entered(command: String):
	# Only process commands if we are in the ACTIVE state
	if current_state != States.ACTIVE:
		return
	var output_label = ui_instance.find_child("OutputLabel")
	var input_line = ui_instance.find_child("InputLine")

	output_label.append_text("\n> " + command)
	input_line.clear()


# First, check if we are waiting for a password.
	if is_waiting_for_password:
		# If the entered command matches the password...
		if command.to_lower() == correct_password.to_lower():
			write_line(output_label, "\n...Password Accepted. Access Granted.")
			# ...send the unlock message to the target.
			if not target_name.is_empty():
				GAME.send_message(target_name, "unlock")
				write_line(output_label, "\n...Signal sent to unlock " + target_name)

		else:
			output_label.append_text("\n...ACCESS DENIED.")

		# Reset the state so we go back to accepting normal commands
		is_waiting_for_password = false
		return # Exit the function

	# *** PARSE COMMAND ***
	# Split the command into parts (e.g., "log list" becomes ["log", "list"])
	var parts = command.strip_edges().split(" ")

	# Terminal Syntax uses a Noun-Verb Relationship
	# Ex: LOG LIST
	var noun = parts[0].to_lower()
	match noun:
		"calc":
			# Expects a format like "calc 12 * 4"
			if parts.size() < 4:
				output_label.append_text("\nUsage: calc <number> <operator> <number>")
				return

			var num1 = parts[1].to_float()
			var op = parts[2]
			var num2 = parts[3].to_float()
			var result = 0.0

			match op:
				"+" : result = num1 + num2
				"-" : result = num1 - num2
				"*" : result = num1 * num2
				"/" : result = num1 / num2
				_: write_error(output_label, "Invalid OPERATOR.")


			write_line(output_label, "\n= " + str(result))

		"display":
			await get_tree().create_timer(0.5).timeout
			await write_line(output_label, "\n")
			await write_chars(output_label, "1010 1010 1010 0011\n", 0.25)
			await write_chars(output_label, "0101 1100 1111 0001\n", 0.25)
			await write_line(output_label, "\n*** END ****")
			done_sound.play()
		"unlock":

			await write_line(output_label, "\nENCRYPTION CODE: ")
			await write_chars(output_label, "00010001 00010111 00010010 00010010 00010110", 0.10)
			await write_line(output_label, "\nENTER PASSWORD: ")
			# Jump to unlock sequence
			is_waiting_for_password = true

		"exit":
			await get_tree().create_timer(0.5).timeout
			_close_terminal()
		"help":
			await get_tree().create_timer(0.5).timeout
			# Uses await to wait for delay otherwise skips
			await write_line(output_label,"\n** COMMANDS **")
			await write_line(output_label, "\nHELP")
			await write_line(output_label, "\nPRINT")
			await write_line(output_label, "\nUNLOCK")
			await write_line(output_label, "\nCALC")
			await write_line(output_label, "\nLOG")
			await write_line(output_label, "\nLIST")
			await write_line(output_label, "\nREAD")
			await write_line(output_label, "\n*** END ****")
			# uses public function to force the scroll
			ui_instance.force_scroll()
			done_sound.play()
		"print":
			await get_tree().create_timer(1.0).timeout
			output_label.append_text("\n")
			var command_filtered = command.substr(5)
			output_label.append_text(command_filtered)
			output_label.append_text("\n*** END ****")
			done_sound.play()
		"log":
			# Make sure there is a second word (the "verb")
			if parts.size() < 2:
				write_error(output_label, "Incomplete command. Try 'log list' or 'log read <number>'.")
				return

			var verb = parts[1].to_lower()

			# Now, match the "verb"
			match verb:
				"list":
					await get_tree().create_timer(0.5).timeout
					output_label.append_text("\nAvailable logs:")
					await get_tree().create_timer(1.0).timeout

					for i in log_entries.size():
						# Add 1 to index to make it user-friendly (1, 2, 3 instead of 0, 1, 2)
						output_label.append_text("\n [" + str(i + 1) + "] " + log_entries[i]["title"])
					# End
					output_label.append_text("\n*** END ****")
					done_sound.play()
					await get_tree().create_timer(1.0).timeout
				"read":
					await get_tree().create_timer(0.5).timeout
					if parts.size() < 3:
						write_error(output_label, "Please specify a log number to read.")
						return

					var log_number = parts[2].to_int()

					await get_tree().create_timer(1.0).timeout

					# Check if the number is valid
					if log_number > 0 and log_number <= log_entries.size():

						# Subtract 1 to get the correct array index
						var entry = log_entries[log_number - 1]
						output_label.append_text("\n\n*** " + entry["title"] + " ***\n")
						output_label.append_text(entry["content"])
						output_label.append_text("\n*** END OF LOG ***")
						done_sound.play()

					else:
						write_error(output_label, "Invalid LOG NUMBER.")
				_:
					write_error(output_label, "Invallid SYNTAX.")
		_:
			write_error(output_label, "Unknown Comand.")

	# Force the label to update its scroll position by toggling the property
	# not sure if this needed but yeah.
	output_label.scroll_following = false
	output_label.scroll_following = true
	# uses public function to force the scroll
	ui_instance.force_scroll()


func _close_terminal():
	# Prevent logic from running a second time. Only enters once.
	if is_instance_valid(ui_instance) and current_state != States.EXITING:
		current_state = States.EXITING
		# Setup UI elements
		var output_label = ui_instance.find_child("OutputLabel")

		output_label.append_text("\n...Connection terminated.")
		await get_tree().create_timer(1.0).timeout

		# uses public function to force the scroll
		ui_instance.force_scroll()
		# Process of freeing instance and re-enable controls
		ui_instance.queue_free()
		ui_instance = null
		# Re-enable player controls
		var player = get_tree().get_first_node_in_group("player")
		if is_instance_valid(player):
			player.set_controls_enabled(true)
		startup_sound.stop()
		# Unpause the game
		get_tree().paused = false


# HELPERS
# display to terminal. Optional delay.
func write_line(output_label, arg:String, delay: float = DEFAULT_DELAY_TIME):
	# uses public function to force the scroll
	ui_instance.force_scroll()
	output_label.append_text(arg)
	beep_sound.play()
	await get_tree().create_timer(delay).timeout


# Typewriter function
func write_chars(output_label, text: String, char_delay: float = DEFAULT_DELAY_TIME):
	# uses public function to force the scroll
	ui_instance.force_scroll()
	# Loop through each character in the text string
	for char in text:
		# Add the single character to the label
		output_label.append_text(char)

		beep_sound.play()
		# Wait for the specified delay
		await get_tree().create_timer(char_delay).timeout
	# uses public function to force the scroll
	ui_instance.force_scroll()

func write_error(output_label, arg:String, delay: float = DEFAULT_DELAY_TIME):
	output_label.append_text("\nERROR: " + arg)
	# Play sound
	error_sound.play()
	await get_tree().create_timer(delay).timeout
