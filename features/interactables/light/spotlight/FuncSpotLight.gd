@tool
class_name FuncSpotLight
extends Node3D
"""
Spot light entity
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
# DONT FORGET TO add @export to applied properties (🙃)(🙃)(🙃)
@export var light_color: Color
@export var mesh_color: Color
@export var light_energy: float
@export var starts_on: bool
@export var is_broken: bool
@onready var light_node = $SpotLight3D
@onready var mesh_node = $EmissionMesh

# NOTE: Have bug with Flicker Random (5). Emission texture not flickering with light src
# Will simply just use is_broken logic instead until fixed
enum PulsePattern { NONE, SINE, COSINE, SQUARE_WAVE, NOISE, FLICKER_RANDOM  }

# --- Add this export variable ---
@export var pulse_pattern: PulsePattern
@export var omni_range: float

var noise = FastNoiseLite.new()

func _func_godot_apply_properties(props: Dictionary):
	# Look in terminal Output after building to see actual state of props recievedww
	print("Raw properties for ", self.name, ": ", props)
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

	# Light Specific Props
	light_color = props.get("light_color", Color(1,1,1,1))
	mesh_color = props.get("mesh_color", Color(1,1,1,1))
	light_energy = props.get("light_energy", 1.0)
	starts_on = props.get("starts_on", true)
	is_broken = props.get("is_broken", false)

	pulse_pattern = props.get("pulse_pattern", 1)
	omni_range = props.get("omni_range", 5)

func _ready() -> void:
	# The code inside will ONLY run when you are playing the game.
	if not Engine.is_editor_hint():
		call_deferred("init_entity")


func init_entity() -> void:
		# Using a random seed ensures every light flickers differently.
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 0.8

	# Init Entity only in game
	if not Engine.is_editor_hint() and GAME:
		GAME.register_entity(self, self.targetname)
	create_sound()
	# Light Init
	light_node.light_color = light_color
	light_node.spot_range = omni_range
	# Make each mesh unique
	if mesh_node.get_active_material(0):
		var unique_material = mesh_node.get_active_material(0).duplicate()
		# 2. Assign this new, unique material to the mesh's override slot.
		mesh_node.material_override = unique_material
	# Modify this particular mesh
	var material = mesh_node.get_active_material(0)
	if material is StandardMaterial3D:
		material.emission_enabled = true
		material.emission = mesh_color

	if starts_on:
		power_on()
		# Added guard for pulse_update
		if pulse_pattern > 0 and PulseManager:
			PulseManager.pulse_updated.connect(_on_pulse_updated)
	else:
		power_off()
# -- Public API Methods

func power_on():
		is_powered = true
		if is_broken and is_powered:
			while is_powered:
					# Turn the light ON
				light_node.visible = true
				# Manually set light_energy for some reason? Not like func light
				light_node.light_energy = light_energy
				mesh_node.get_active_material(0).emission_enabled = true
				# Wait for a short, random "ON" duration
				await get_tree().create_timer(randf_range(0.05, 2)).timeout
				# Turn the light OFF
				light_node.visible = false
				# Manually set light_energy for some reason? Not like func light
				light_node.light_energy = 0
				mesh_node.get_active_material(0).emission_enabled = false

				# Wait for a slightly longer, random "OFF" duration
				await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
		else:
			light_node.light_energy = light_energy
			mesh_node.get_active_material(0).emission_enabled = true
			if is_instance_valid(press_sound):
				SoundManager.play_sound_event(press_sound, self.global_position)
			print(self.targetname, " is now powered ON.")


func power_off():
	is_powered = false
	light_node.light_energy = 0
	mesh_node.get_active_material(0).emission_enabled = false
	if is_instance_valid(press_sound):
		SoundManager.play_sound_event(press_sound, self.global_position)
	print(self.targetname, " is now powered OFF.")

func enable():
	is_enabled = true

func disable():
	is_enabled = false


func use():
	if is_powered:
		power_off()
	else:
		power_on()



# --- Helper Functions ---
# This new function will be called every frame by the PulseManager's signal
func _on_pulse_updated(total_time: float):
	# Don't do anything if we aren't supposed to be pulsating or powered
	if pulse_pattern == PulsePattern.NONE or not is_powered:
		return

	var pulse_value: float = 0.0

	# Use a match statement to select the pattern
	match pulse_pattern:
		PulsePattern.SINE:
			pulse_value = sin(total_time * PulseManager.pulse_speed)
		PulsePattern.COSINE:
			pulse_value = cos(total_time * PulseManager.pulse_speed)
		PulsePattern.SQUARE_WAVE:
			pulse_value = 1.0 if fmod(total_time, 2.0) > 1.0 else -1.0
		PulsePattern.NOISE:
			# The light now generates its own noise using the global time
			pulse_value = noise.get_noise_1d(total_time * 10.0)
		PulsePattern.FLICKER_RANDOM:
			# If we are random, we don't need to connect to the global pulse
			pass
	var intensity = (pulse_value + 1.0) / 2.0 # Remap [-1, 1] to [0, 1]

	light_node.light_energy = light_energy * intensity
	var material = mesh_node.get_active_material(0)
	if material is StandardMaterial3D:
		# Allows textures to turn on if off.
		material.emission_enabled = true

		material.emission_energy_multiplier = intensity



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
