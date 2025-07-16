# In water_zone.gd
extends Area3D

@export var overlay_rect: ColorRect

var overlay_material: ShaderMaterial
var active_tween: Tween

func _ready():
	if overlay_rect:
		overlay_material = overlay_rect.material
		overlay_material.set_shader_parameter("overlay_color", Color(0,0,0,0))
		overlay_material.set_shader_parameter("distortion_strength", 0.0)
	
	# Connect signals for both Area3D (camera) and PhysicsBody3D (player)
	area_entered.connect(_on_detector_entered)
	area_exited.connect(_on_detector_exited)
	body_entered.connect(_on_detector_entered)
	body_exited.connect(_on_detector_exited)

# This single function handles all entering bodies/areas
func _on_detector_entered(detector):
	# Check if it's the player's body for PHYSICS
	if detector.is_in_group("player"):
		print("Player body entered water!")
		detector.enter_swim_state()
		
	# Check if it's the camera's detector for VISUALS
	if detector.is_in_group("camera_detector"):
		print("Camera detector entered water!")
		animate_effect(Color(0.1, 0.3, 0.5, 0.25), 0.01)

# This single function handles all exiting bodies/areasw
func _on_detector_exited(detector):
	# Handle player body exiting
	if detector.is_in_group("player"):
		print("Player body exited water!")
		detector.exit_swim_state()
		
	# Handle camera detector exiting
	if detector.is_in_group("camera_detector"):
		print("Camera detector exited water!")
		animate_effect(Color(0,0,0,0), 0.0)

func animate_effect(target_color: Color, target_distortion: float):
	if not overlay_material: return

	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(overlay_material, "shader_parameter/overlay_color", target_color, 1.0)
	active_tween.tween_property(overlay_material, "shader_parameter/distortion_strength", target_distortion, 1.0)
