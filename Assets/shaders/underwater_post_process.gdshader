shader_type canvas_item;

// We can control these values from our script to fade the effect in and out.
uniform vec4 overlay_color : source_color = vec4(0.1, 0.3, 0.5, 0.25);
uniform float distortion_strength = 0.01;
uniform sampler2D SCREEN_TEXTURE :hint_screen_texture, filter_linear_mipmap;
void fragment() {
	// Get the color of the screen behind this rectangle.
	vec3 scene_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

	// Create a simple distortion using a scrolling noise pattern.
	vec2 distorted_uv = SCREEN_UV + vec2(sin(TIME * 1.5) * distortion_strength, cos(TIME) * distortion_strength);
	vec3 distorted_color = texture(SCREEN_TEXTURE, distorted_uv).rgb;

	// Mix the original scene color with our underwater tint.
	vec3 final_color = mix(distorted_color, overlay_color.rgb, overlay_color.a);

	// Apply the final color.
	COLOR.rgb = final_color;
}
