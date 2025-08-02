@tool
extends Area3D
"""
Button Entity
"""

"""
Entity properties for func_godot
"""
# Base Class Props
@export var target: String = ""
@export var targetname: String = ""
@export var room_id: String = ""
@export var is_enabled: bool

# Eletrical Props
@export var is_powered: bool
# Audible Props
@export var press_sound: SoundEvent
@export var press_sound_file: String
@export var press_sound_vol: float
@export var press_sound_pitch: float

@export var release_sound : SoundEvent
@export var release_sound_file: String
@export var release_sound_vol: float
@export var release_sound_pitch: float
var file_tail = "res://Assets/Sounds/"

# -- Entity Specific
var player_is_near = false



func _func_godot_apply_properties(props: Dictionary):
	# Base Class Props
	target = props.get("target", "")
	targetname  = props.get("targetname", "")
	room_id = props.get("room_id", "")
	is_enabled = props.get("is_enabled", false)
	# Eletrical Props
	is_powered = props.get("is_powered", false)
	# Audible Props
	press_sound_file = props.get("press_sound_file", "")
	press_sound_vol = props.get("press_sound_vol", 1.0)
	press_sound_pitch = props.get("press_sound_pitch", 1.0)

	release_sound_file = props.get("release_sound_file", "")
	release_sound_vol = props.get("release_sound_vol", 1.0)
	release_sound_pitch = props.get("release_sound_pitch", 1.0)

	print("Button A", is_powered)



func _ready() -> void:
	# Init Entity only in game
	if not Engine.is_editor_hint() and GAME:
		GAME.register_entity(self, self.targetname)
	#debug_sound_files()
	create_sound()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false

func _input(event):
	if player_is_near and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		use()


# -- Public API Methods

func power_on():
	is_powered = true
	print(self.targetname, " is now powered ON.")

func power_off():
	is_powered = false
	print(self.targetname, " is now powered OFF.")

func enable():
	is_enabled = true

func disable():
	is_enabled = false
func use():
		print("Button pressed! Telling GAME to activate target: '", target, "'")

		if is_powered and is_enabled:
			if not target.is_empty():
				SoundManager.play_sound_event(press_sound, self.global_position)
				GAME.send_message(self.target, "use")
		else:
			SoundManager.play_sound_event(release_sound, self.global_position)
			print("NOT POWERED")


# --- Helper Functions ---

func create_sound() -> void:
# Only try to create and load the sound if a file was provided
	if not press_sound_file.is_empty():
		press_sound = SoundEvent.new()
		press_sound.stream = load(file_tail + press_sound_file)
		press_sound.volume_db = press_sound_vol
		press_sound.pitch_scale = press_sound_pitch
	else:
		# If no file was provided, press_sound will remain null.
		press_sound = null

	# Create a separate, independent check for the release_sound
	if not release_sound_file.is_empty():
		release_sound = SoundEvent.new()
		release_sound.stream = load(file_tail + release_sound_file)
		release_sound.volume_db = release_sound_vol
		release_sound.pitch_scale = release_sound_pitch
	else:
		release_sound = null

func debug_sound_files() -> void:
	print("--- Data from TrenchBroom for ", self.name, " ---")
	print("Press Sound File: '", press_sound_file, "'")
	print("Release Sound File: '", release_sound_file, "'")
	print("-----------------------------------------")
