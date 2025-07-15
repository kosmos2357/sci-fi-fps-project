# In water_zone.gd
extends Area3D

# We will drag our UnderwaterOverlay ColorRect into this slot.
@export var overlay_rect: ColorRect

# We store the material so we can access its shader parameters.
var overlay_material: ShaderMaterial
var active_tween: Tween

func _ready():
	# Get the material from the overlay rectangle when the game starts.
	if overlay_rect:
		overlay_material = overlay_rect.material
		# Start with the effect turned off completely.
		overlay_material.set_shader_parameter("overlay_color", Color(0,0,0,0))
		overlay_material.set_shader_parameter("distortion_strength", 0.0)
	
	# Connect our signals.
	area_entered.connect(_on_camera_entered)
	area_exited.connect(_on_camera_exited)

func _on_camera_entered(area):
	print("Camera entered water!")
	# Animate the shader properties TO their underwater values.
	animate_effect(Color(0.1, 0.3, 0.5, 0.25), 0.01)

func _on_camera_exited(area):
	print("Camera exited water!")
	# Animate the shader properties back TO zero.
	animate_effect(Color(0,0,0,0), 0.0)

func animate_effect(target_color: Color, target_distortion: float):
	if not overlay_material: return

	if active_tween and active_tween.is_running():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.set_parallel(true)
	
	# We are now tweening the "uniform" variables inside our shader.
	active_tween.tween_property(overlay_material, "shader_parameter/overlay_color", target_color, 1.0)
	active_tween.tween_property(overlay_material, "shader_parameter/distortion_strength", target_distortion, 1.0)
