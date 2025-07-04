# The Final, Definitive Procedural Terrain Generator
@tool
extends MeshInstance3D

# --- Base Settings ---
@export_group("Generation Settings")
@export var terrain_size := Vector2(512, 512)
@export_range(4, 256, 4) var resolution := 128

# --- Biome Noise Layers ---
@export_group("Biome Noise Layers")
# This noise map decides WHERE the biomes go.
@export var biome_map: FastNoiseLite

# This is the noise for our first biome (e.g., Plains).
@export var biome_a_noise: FastNoiseLite
@export var biome_a_height: float = 20.0

# This is the noise for our second biome (e.g., Mountains).
@export var biome_b_noise: FastNoiseLite
@export var biome_b_height: float = 80.0


# --- Manual Trigger ---
@export_group("Manual Update")
# A reliable button to force an update if needed.
@export var regenerate: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			print("Manual regeneration triggered!")
			update_mesh()


func _ready():
	# Only generate in the editor when the script is first run.
	# The 'regenerate' button is the main way to update.
	if Engine.is_editor_hint():
		update_mesh()

# This is the NEW, simpler height function.
func get_height(x: float, z: float) -> float:
	# Add a "guard clause" to ensure all noise maps exist before we use them.
	# This prevents the "call on a null value" crash.
	if not (biome_map and biome_a_noise and biome_b_noise):
		return 0.0

	# First, check the master biome map.
	var biome_value = biome_map.get_noise_2d(x, z)
	
	# Use a simple "if" statement to choose which biome to generate.
	if biome_value > 0.0:
		# If the biome map value is positive, use Biome A's noise.
		return biome_a_noise.get_noise_2d(x, z) * biome_a_height
	else:
		# If the biome map value is negative, use Biome B's noise.
		return biome_b_noise.get_noise_2d(x, z) * biome_b_height


# This is the main function that builds our mesh.
func update_mesh() -> void:
	if not (biome_map and biome_a_noise and biome_b_noise):
		print("ERROR: Please assign all three noise maps in the Inspector.")
		return
		
	print("Updating terrain mesh with biome logic...")
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z_segment in range(resolution + 1):
		for x_segment in range(resolution + 1):
			var vx = (float(x_segment) / resolution - 0.5) * terrain_size.x
			var vz = (float(z_segment) / resolution - 0.5) * terrain_size.y
			
			var vy = get_height(vx, vz)
			st.add_vertex(Vector3(vx, vy, vz))

	for z_segment in range(resolution):
		for x_segment in range(resolution):
			var a = z_segment * (resolution + 1) + x_segment
			var b = a + 1
			var c = (z_segment + 1) * (resolution + 1) + x_segment
			var d = c + 1
			
			# --- THE FIX: Winding order corrected to be counter-clockwise ---
			# First triangle of the quad
			st.add_index(a); st.add_index(b); st.add_index(c)
			
			# Second triangle of the quad
			st.add_index(b); st.add_index(d); st.add_index(c)

	st.generate_normals()
	
	var array_mesh = st.commit()
	self.mesh = array_mesh
	print("Terrain mesh update complete!")
