class_name SoundComponent
extends Node

@onready var sfx_player = {
	"useKeySound" : $UseKeySound,
	"flashlight_key" : $FlashLightClickSound,
	"jumpsound" : $JumpSound,
}

func play_sound(sound_name: String):
	if sfx_player.has(sound_name):
		sfx_player[sound_name].play()
