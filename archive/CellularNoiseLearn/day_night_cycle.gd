# In DayNightCycle.gd
extends Node3D

# --- Node References ---
@onready var sun_light = $DirectionalLight3D
@onready var world_environment = $WorldEnvironment

# --- Settings ---
@export_group("Cycle Settings")
# How many REAL-WORLD seconds it takes for a full in-game day to pass.
@export var seconds_per_day: float = 60.0 

@export_group("Sky Textures")
# The panoramic texture for your starry night sky.
@export var night_sky_panorama: Texture2D

# We will store our two sky materials here.
var day_sky_material: ProceduralSkyMaterial
var night_sky_material: PanoramaSkyMaterial

# This variable will track the current time of day, from 0.0 to 1.0.
var time_of_day: float = 0.0 # Start at sunrise (0.25 = 6 AM)

enum States {MIDNIGHT, MORNING, NOON, EVENING}
func _ready():
	if not world_environment.environment:
		print("ERROR: No Environment resource set on WorldEnvironment node.")
		return

	world_environment.environment = world_environment.environment.duplicate()

	if world_environment.environment.sky and world_environment.environment.sky.sky_material is ProceduralSkyMaterial:
		day_sky_material = world_environment.environment.sky.sky_material
	else:
		print("ERROR: Default sky material not found or is not a ProceduralSkyMaterial.")
		return

	night_sky_material = PanoramaSkyMaterial.new()
	night_sky_material.panorama = night_sky_panorama

var total_time_elapsed: float = 0.0
var ten_second_progress: float = 0.0

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func get_state_from_time(current_time: float) -> States:
	if current_time >= 0.25 and current_time < 0.50:
		return States.MORNING
	elif current_time >= 0.50 and current_time < 0.75:
		return States.NOON
	elif current_time >= 0.75 and current_time < 1.0:
		return States.EVENING
	else: # Covers everything from 0.0 to 0.249...
		return States.MIDNIGHT
func _process(delta):
	
	if not day_sky_material:
		return
	
	## EXERCISE 1: The "Heartbeat" Light (Using raw time)
	## This shows how to use a simple accumulator for cyclical effects.
	#total_time_elapsed += delta
	## We use sin() because it naturally creates a smooth -1 to 1 wave.
	## abs() makes it a pulsing 0 to 1 wave.
	#print("total_time_elapsed", total_time_elapsed)
	
	## How fast 
	#var frequency = 2
	## how high
	#var amplitude = 2
	#sun_light.light_energy = (abs(sin(total_time_elapsed * frequency)) * amplitude) * abs(cos(total_time_elapsed))# Pulse between 0 and 2 energy
	
	# 1. Update the time of day.
	time_of_day += delta / seconds_per_day
	
	time_of_day = fmod(time_of_day, 1.0) # Use fmod to loop time between 0.0 and 1.0
	
	# _ Pattern guards
	#https://forum.godotengine.org/t/can-i-check-for-a-range-with-the-match-statement/11778/5
	var current_state = get_state_from_time(time_of_day)
	
	# 2. Act based on that state
	match current_state:
		States.MORNING:
			print("It's morning! Do morning things.")
			
		States.NOON:
			print("It's noon! Do noon things.")
			
		States.EVENING:
			print("It's evening! Do evening things.")
			
		States.MIDNIGHT:
			print("It's midnight! Do midnight things.")
			
	#print(time_of_day)
	# 2. Rotate the sun.
	# We rotate from 90 (sunrise) to 270 degrees.
	self.rotation_degrees.x = (time_of_day * 360.0) + 90.0

	# 3. Blend the skies using a more robust method.
	# Sunrise is at 0.25, Noon is at 0.5, Sunset is at 0.75

	# Check if we are in the "day" portion of the cycle
	if time_of_day > 0.25 and time_of_day < 0.75:
		# --- DAY LOGIC ---
		if world_environment.environment.sky.sky_material != day_sky_material:
			world_environment.environment.sky.sky_material = day_sky_material

		# Calculate how far we are into the day (0.0 at sunrise, 1.0 at noon, 0.0 at sunset)
		var day_progress = 1.0 - (abs(time_of_day - 0.5) * 4.0)
		var day_fade = smoothstep(0.0, 1.0, day_progress)

		day_sky_material.energy_multiplier = day_fade
		world_environment.environment.ambient_light_sky_contribution = day_fade
	else:
		# --- NIGHT LOGIC ---
		if world_environment.environment.sky.sky_material != night_sky_material:
			world_environment.environment.sky.sky_material = night_sky_material

		# Calculate how far we are into the night
		var night_progress
		if time_of_day > 0.75:
			night_progress = (time_of_day - 0.75) * 4.0
		else: # time_of_day is between 0.0 and 0.25
			night_progress = (0.25 - time_of_day) * 4.0
		
		# Use this for sky_contribution
		var night_fade = smoothstep(0.5, -1.0, night_progress)
	
		var night_fade_in = smoothstep(0.5, 1.0, night_progress + .5)
		
		#print("night_fade_in", night_fade_in, " Correspond to night progress: ", night_progress)

		night_sky_material.energy_multiplier = night_fade_in
		
		# The 2.0 gives a slight green glow too landscape at darkest point 
		world_environment.environment.ambient_light_sky_contribution = 2.0 - night_fade
