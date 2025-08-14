# The final SoundManager.gd
extends Node

var world_sfx_pool: Array[AudioStreamPlayer3D] = []

func _ready():
	print("--- SoundManager _ready() START ---")

	world_sfx_pool = []
	var children = get_children()

	print("Found ", children.size(), " children to check.")

	for child in children:
		print("Checking child: '", child.name, "', with type: '", child.get_class(), "'")
		if child is AudioStreamPlayer3D:
			print("   -> It's an AudioStreamPlayer3D! Adding to pool.")
			world_sfx_pool.append(child)

	print("--- SoundManager _ready() END --- Final pool size: ", world_sfx_pool.size())


func play_sound_event(event: SoundEvent, position: Vector3):
	# This check is very important to prevent the bug from happening again.
	if not event or not event.stream:
		print("ERROR: Tried to play a sound event with no AudioStream.")
		return

	print("Playing sound with Volume: ", event.volume_db, " and Pitch: ", event.pitch_scale)

	print("Attempting to play sound. Pool size: ", world_sfx_pool.size())
	for player in world_sfx_pool:
		# ADD THIS: Chweck the status of each player in the pool.
		print("Checking player '", player.name, "'. Is playing: ", player.is_playing())

		if not player.is_playing():
			print("Found available player: '", player.name, "'. Playing sound.")

			player.stream = event.stream
			player.global_position = position
			player.volume_db = event.volume_db
			player.pitch_scale = event.pitch_scale
			player.play()
			return

	print("Sound pool is busy! No available players found.")
