shader_type canvas_item;

uniform vec4 dim_color : source_color = vec4(0.04, 0.03, 0.025, 0.78);
uniform vec2 viewport_size;
uniform vec2 hole_center_px;
uniform float hole_radius_px;
uniform float edge_softness = 4.0;

void fragment() {
	vec2 pixel = UV * viewport_size;
	float dist = distance(pixel, hole_center_px);
	float alpha = dim_color.a * smoothstep(hole_radius_px - edge_softness, hole_radius_px + edge_softness, dist);
	COLOR = vec4(dim_color.rgb, alpha);
}
