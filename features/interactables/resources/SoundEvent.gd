"""
Sound Object to be used in BaseAudible class for func_godot
"""
class_name SoundEvent
extends Resource

@export var stream: AudioStream
@export var volume_db: float = 1.0
@export var pitch_scale: float = 1.0
