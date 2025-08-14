# In lure.gd
extends Area3D



@export var fade_in_time = 0.5
@export var fade_out_time = 1.5

# How long the lure will exist in seconds
@export var lifetime = 5.0
@onready var decal = $Decal
func _ready():
	# --- Animation Setup ---
	# 1. Start with the decal completely invisible
	decal.modulate.a = 0.0

	# 2. Create a tween to handle the fade animations
	var tween = create_tween()

	# 3. Animate the fade-in
	# Animate the 'a' (alpha) component of the modulate property to 1.0
	tween.tween_property(decal, "modulate:a", 1.0, fade_in_time)

	# 4. Animate the fade-out
	# This will start after the fade-in tween is complete
	tween.tween_property(decal, "modulate:a", 0.0, fade_out_time).set_delay(lifetime - fade_out_time)

	# --- Original Lure Logic ---
	# (The lure detection logic runs in parallel to the animation)
	await get_tree().process_frame
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.has_method("lure_to_position"):
			body.lure_to_position(self.global_position)

	body_entered.connect(_on_body_entered)

	# Set the lure to delete itself after its lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body):
	if body.has_method("lure_to_position"):
		body.lure_to_position(self.global_position)
