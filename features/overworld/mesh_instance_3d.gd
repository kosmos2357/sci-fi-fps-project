@tool
extends MeshInstance3D

# This now correctly controls the X and Z size of your plane.
@export var terrain_size := Vector2(256, 256):
	set(value):
		terrain_size = value
		update_mesh()


@export_range(4, 256, 4) var resolution := 32:
	set(new_resolution):
		resolution = new_resolution
		update_mesh()

@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_mesh()
		if noise:
			noise.changed.connect(update_mesh)

@export_range(4.0, 128.0, 4.0) var height := 64.0:
	set(new_height):
		height = new_height
		material_override.set_shader_parameter("height", height * 2.0)
		update_mesh()

func get_height(x: float, y: float) -> float:
	return noise.get_noise_2d(x, y) * height

func get_normal(x: float, y: float) -> Vector3:
	var epsilon := terrain_size.x / resolution
	var normal := Vector3(
		(get_height(x + epsilon, y) - get_height(x - epsilon, y)) / (2.0 * epsilon),
		1.0,
		(get_height(x, y + epsilon) - get_height(x, y - epsilon)) / (2.0 * epsilon),
	)
	return normal.normalized()

func update_mesh() -> void:
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = terrain_size
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array: PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]
	
	for i:int in vertex_array.size():
		var vertex := vertex_array[i]
		var normal := Vector3.UP
		var tangent := Vector3.RIGHT
		if noise:
			vertex.y = get_height(vertex.x, vertex.z)
			normal = get_normal(vertex.x, vertex.z)
			tangent = normal.cross(Vector3.UP)
		vertex_array[i] = vertex
		normal_array[i] = normal
		tangent_array[4 * i] = tangent.x
		tangent_array[4 * i + 1] = tangent.y
		tangent_array[4 * i + 2] = tangent.z
	
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh = array_mesh



# --- Prop Scattering Settings ---
@export_group("Prop Scattering")
@export var props_to_scatter: Array[PackedScene] # The prop scene to place (e.g., your tree)
@export var prop_count: int = 500       # How many props to try and place
@export var water_level: float = 0.0      # Any point below this height is considered water

# This runs once when the game starts.
func _ready():
	# If the game is running (NOT in the editor), generate the mesh once
	# and then scatter the props.
	if not Engine.is_editor_hint():
		update_mesh()
		scatter_props_simple()


# The Simple Scattering Function
func scatter_props_simple():
	if props_to_scatter == null: return
	
	var prop_container = find_child("ScatteredProps", true, false)
	if not is_instance_valid(prop_container):
		prop_container = Node3D.new()
		prop_container.name = "ScatteredProps"
		add_child(prop_container)
	
	for child in prop_container.get_children():
		child.queue_free()

	
	for i in range(prop_count):
		var random_x = randf_range(-terrain_size.x / 2, terrain_size.x / 2)
		var random_z = randf_range(-terrain_size.y / 2, terrain_size.y / 2)
		var ground_y = get_height(random_x, random_z)
		# Handles Water
		if ground_y > water_level:
			var random_prop_scene = props_to_scatter.pick_random()
			if random_prop_scene:
				var prop_instance = random_prop_scene.instantiate()
				prop_container.add_child(prop_instance)
				
				var final_position = Vector3(random_x, ground_y, random_z)
				# prop.call_deffered fixes race condition issue 
				# Cant simply add_child. We must set it to call_defferred, its positioning, and position
				prop_instance.call_deferred("set_global_position", final_position)
				prop_instance.call_deferred("set_rotation", Vector3(0, randf_range(0, TAU), 0))
