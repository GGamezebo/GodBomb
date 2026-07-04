shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform vec2 ripple_origin;
uniform float ripple_progress;
uniform float ripple_max_radius;
uniform float aspect_ratio;
uniform vec4 color_from : source_color;
uniform vec4 color_to : source_color;

const float DISTORTION = 0.14;

vec2 to_scaled(vec2 uv) {
	vec2 delta = uv - ripple_origin;
	return vec2(delta.x * aspect_ratio, delta.y);
}

vec2 from_scaled_dir(vec2 dir) {
	return vec2(dir.x / aspect_ratio, dir.y);
}

float dense_waves(float dist, float front, float strength) {
	float phase = dist * 72.0 - ripple_progress * 28.0;
	float w = sin(phase) * 0.72;
	w += sin(phase * 1.65 + 0.9) * 0.42;
	w += sin(phase * 2.35 - 1.4) * 0.24;
	w += sin(phase * 3.1 + 2.1) * 0.14;
	float packet = exp(-pow((dist - front) / 0.14, 2.0));
	float trail = exp(-pow((dist - front * 0.55) / 0.18, 2.0)) * (1.0 - ripple_progress) * 0.55;
	return w * (packet * 1.15 + trail + 0.35) * strength;
}

float visible_rings(float dist, float front, float strength) {
	float rings = 0.0;
	for (int i = 0; i < 14; i++) {
		float fi = float(i);
		float radius = front - fi * 0.028;
		float band = smoothstep(0.038, 0.0, abs(dist - radius));
		rings += band * max(0.0, 1.0 - fi * 0.055);
	}
	return rings * strength;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 scaled = to_scaled(uv);
	float dist = length(scaled);
	vec2 dir = dist > 0.0001 ? scaled / dist : vec2(0.0, 1.0);

	float front = ripple_progress * ripple_max_radius;
	float life = sin(ripple_progress * 3.14159);
	float global = mix(0.55, 1.0, life) * (1.0 - ripple_progress * 0.12);
	float inside = 1.0 - smoothstep(ripple_max_radius * 1.04, ripple_max_radius * 0.78, dist);
	float strength = global * mix(0.75, 1.0, inside);

	float waves = dense_waves(dist, front, strength);
	float lens = exp(-pow((dist - front) / 0.16, 2.0)) * 1.35 * strength;
	float radial_push = exp(-dist * 2.4) * ripple_progress * 0.45 * strength;
	float total = waves + lens + radial_push;

	vec2 offset = from_scaled_dir(dir) * total * DISTORTION;
	vec2 perp = vec2(-dir.y, dir.x);
	offset += from_scaled_dir(perp) * sin(dist * 58.0 - ripple_progress * 22.0) * 0.028 * strength;
	offset += from_scaled_dir(dir) * sin(dist * 34.0 - ripple_progress * 13.0) * 0.016 * strength;

	vec2 sample_uv = clamp(uv + offset, vec2(0.001), vec2(0.999));
	vec2 ca = offset * 0.35;
	float r = texture(screen_texture, clamp(sample_uv + ca, vec2(0.001), vec2(0.999))).r;
	float g = texture(screen_texture, sample_uv).g;
	float b = texture(screen_texture, clamp(sample_uv - ca, vec2(0.001), vec2(0.999))).b;
	vec3 col = vec3(r, g, b);

	float passed = 1.0 - smoothstep(front - 0.02, front + 0.012, dist);
	vec3 tint = mix(color_from.rgb, color_to.rgb, passed);
	col = mix(col, col * tint + tint * 0.18, passed * 0.72);

	float rings = visible_rings(dist, front, strength);
	vec3 ring_color = mix(vec3(1.0), tint + vec3(0.35), 0.4);
	col = mix(col, ring_color * 1.15, rings * 0.82);
	col += ring_color * rings * 0.55;

	COLOR = vec4(col, 1.0);
}
