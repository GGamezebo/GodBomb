shader_type canvas_item;

uniform vec4 dim_color : source_color = vec4(0.04, 0.03, 0.025, 0.78);
uniform vec2 viewport_size;
uniform vec2 hole_center_px;
uniform float hole_radius_px;
uniform float edge_softness = 4.0;
uniform vec4 ring_color : source_color = vec4(0.88, 0.62, 0.38, 0.9);
uniform float ring_width = 5.0;

void fragment() {
	vec2 pixel = UV * viewport_size;
	float dist = distance(pixel, hole_center_px);
	float alpha = dim_color.a * smoothstep(hole_radius_px - edge_softness, hole_radius_px + edge_softness, dist);
	// Copper ring breathing just outside the hole edge.
	float pulse = 0.5 + 0.5 * sin(TIME * 4.0);
	float ring_radius = hole_radius_px + 6.0 + pulse * 8.0;
	float ring = smoothstep(ring_width, 0.0, abs(dist - ring_radius)) * ring_color.a * (0.55 + 0.45 * pulse);
	COLOR = vec4(mix(dim_color.rgb, ring_color.rgb, ring), max(alpha, ring));
}
