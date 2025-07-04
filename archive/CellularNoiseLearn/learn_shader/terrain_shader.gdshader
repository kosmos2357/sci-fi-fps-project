shader_type spatial;

// --- Textures ---
// We will assign our textures to these slots in the Inspector.
uniform sampler2D texture_low;  // e.g., Sand
uniform sampler2D texture_mid;  // e.g., Grass
uniform sampler2D texture_high; // e.g., Rock

// --- Blending Controls ---
// These control how high each texture layer goes.
uniform float height_low = 10.0;
uniform float height_mid = 40.0;
// This controls how smooth the transition is between textures.
uniform float blend_sharpness = 8.0;

// A "varying" is a variable used to pass data from the vertex function to the fragment function.
varying vec3 world_pos;

void vertex() {
	// We calculate the world position here, in the vertex function where it's allowed.
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Project our textures from three directions (top, front, side)
	// This avoids stretching on steep cliffs.
	vec3 blend_weights = abs(NORMAL);
	blend_weights = blend_weights / (blend_weights.x + blend_weights.y + blend_weights.z);

	// Sample the textures based on world position.
	// We use the 'world_pos' varying that we calculated in the vertex function.
	vec4 low_tex_y = texture(texture_low, world_pos.xz);
	vec4 low_tex_z = texture(texture_low, world_pos.xy);
	vec4 low_tex_x = texture(texture_low, world_pos.zy);

	vec4 mid_tex_y = texture(texture_mid, world_pos.xz);
	vec4 mid_tex_z = texture(texture_mid, world_pos.xy);
	vec4 mid_tex_x = texture(texture_mid, world_pos.zy);
	
	vec4 high_tex_y = texture(texture_high, world_pos.xz);
	vec4 high_tex_z = texture(texture_high, world_pos.xy);
	vec4 high_tex_x = texture(texture_high, world_pos.zy);

	// Blend the X, Y, and Z projections together for each texture.
	vec4 triplanar_low = low_tex_y * blend_weights.y + low_tex_z * blend_weights.x + low_tex_x * blend_weights.z;
	vec4 triplanar_mid = mid_tex_y * blend_weights.y + mid_tex_z * blend_weights.x + mid_tex_x * blend_weights.z;
	vec4 triplanar_high = high_tex_y * blend_weights.y + high_tex_z * blend_weights.x + high_tex_x * blend_weights.z;

	// --- Height Blending Logic ---
	// Calculate the blend factor for the first transition (low to mid).
	float blend1 = smoothstep(height_low - blend_sharpness, height_low + blend_sharpness, world_pos.y);
	// Calculate the blend factor for the second transition (mid to high).
	float blend2 = smoothstep(height_mid - blend_sharpness, height_mid + blend_sharpness, world_pos.y);

	// Mix the textures together based on the blend factors.
	vec4 final_color = mix(triplanar_low, triplanar_mid, blend1);
	final_color = mix(final_color, triplanar_high, blend2);

	// Apply the final color to the mesh.
	ALBEDO = final_color.rgb;
}
