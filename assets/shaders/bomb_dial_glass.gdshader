shader_type canvas_item;
render_mode blend_mix;

uniform float glass_alpha : hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float rim_strength : hint_range(0.0, 1.0, 0.01) = 0.48;
uniform float spec_strength : hint_range(0.0, 1.0, 0.01) = 0.36;
uniform vec4 tint_color : source_color = vec4(0.9, 0.95, 1.0, 1.0);

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float dist = length(p);
	if (dist > 1.0) {
		discard;
	}

	float fill = (1.0 - dist * dist) * glass_alpha;
	float outer_rim = smoothstep(0.78, 0.94, dist) * (1.0 - smoothstep(0.94, 1.0, dist));
	float inner_ring = smoothstep(0.58, 0.7, dist) * (1.0 - smoothstep(0.7, 0.8, dist));

	vec2 spec_center = vec2(-0.32, -0.4);
	float spec = exp(-dot(p - spec_center, p - spec_center) * 7.5);
	float spec_soft = exp(-dot(p - vec2(0.22, -0.12), p - vec2(0.22, -0.12)) * 18.0) * 0.22;

	float vignette = mix(0.82, 1.0, 1.0 - dist * dist * 0.4);
	vec3 col = tint_color.rgb * vignette;
	col += vec3(1.0) * (outer_rim * rim_strength + spec * spec_strength + spec_soft);
	col -= vec3(inner_ring * 0.12);

	float alpha = fill + outer_rim * 0.22 + spec * 0.18 + spec_soft;
	alpha = clamp(alpha, 0.0, 0.52);

	COLOR = vec4(col, alpha);
}
