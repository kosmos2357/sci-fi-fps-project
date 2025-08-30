# TerminalUI.gd
extends PanelContainer

@onready var input_line = $MarginContainer/VBoxContainer/HBoxContainer/InputLine
@onready var scroll_container = $MarginContainer/VBoxContainer/ScrollContainer

@onready var keypress_sound_player = $AudioStreamPlayer
@onready var submit_sound_player = $AudioStreamPlayer2
func _ready():
	# Connect the signal from the input line to a new function on this script
	input_line.text_changed.connect(_on_text_changed)
	input_line.text_submitted.connect(_on_text_submitted)
# This function will be called every time a key is pressed in the input line
func _on_text_changed(new_text: String):
	keypress_sound_player.play()
	call_deferred("_force_scroll_to_bottom")


func _on_text_submitted(text: String):
	submit_sound_player.play()
	call_deferred("_force_scroll_to_bottom")


func _force_scroll_to_bottom():
	# Wait one frame to ensure the label has resized, then scroll
	await get_tree().process_frame
	scroll_container.get_v_scroll_bar().value = scroll_container.get_v_scroll_bar().max_value
func force_scroll():
	call_deferred("_force_scroll_to_bottom")
