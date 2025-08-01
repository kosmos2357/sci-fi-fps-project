# door.gd
@tool
class_name FuncDoor
extends AnimatableBody3D





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


# --- Door-Specific Properties ---
@export var move_offset: Vector3
@export var speed: float = 3.0
@export var is_locked: bool


var is_open: bool = false

var start_position: Vector3
var end_position: Vector3

# This function is called by the func_godot importer
func _func_godot_apply_properties(props: Dictionary):
	# Func_Godot DEBUG
	# Look in terminal Output after building to see actual state of props recievedww
	#print("Raw properties for ", self.name, ": ", props)
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

	# Entity Specific
	move_offset = props.get("move_offset", Vector3.ZERO)
	speed = props.get("speed", 3.0)
	is_locked = props.get("is_locked", false)


func _ready():
	# Register with the GameManager's "phone book"
	if not Engine.is_editor_hint() and GAME:
		GAME.register_entity(self, targetname)

	create_sound()
	# Setup positions
	start_position = global_position
	end_position = start_position + move_offset

# --- Public API (The messages other entities can send) ---
	# Debug
	print("is_powered: ", is_powered, "  is_locked:: ", is_locked)


func use():
	# The door checks its OWN internal state
	if is_locked or not is_powered:
		print("Door '", targetname, "' cannot be used.")
		# Play a 'deny' sound here
		SoundManager.play_sound_event(release_sound, self.global_position)
		return

	is_open = not is_open
	var destination = end_position if is_open else start_position

	var tween = create_tween()
	tween.tween_property(self, "global_position", destination, speed)
	# Play 'open' or 'close' sound here
	SoundManager.play_sound_event(press_sound, self.global_position)

func unlock():
	is_locked = false
	print("Door '", targetname, "' unlocked.")

func lock():
	is_locked = true
	print("Door '", targetname, "' locked.")

func power_on():
	is_powered = true
	print("Door '", targetname, "' powered ON.")

func power_off():
	is_powered = false
	print("Door '", targetname, "' powered OFF.")

func enable():
	is_enabled = true

func disable():
	is_enabled = false


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
