shader_type canvas_item;

uniform sampler2D source_tex : filter_linear, repeat_disable;
uniform float blur_radius : hint_range(0.0, 16.0) = 5.0;

void fragment() {
	ivec2 tex_size = textureSize(source_tex, 0);
	vec2 texel = vec2(1.0 / float(tex_size.x), 1.0 / float(tex_size.y)) * blur_radius;
	vec4 color = vec4(0.0);
	float weight_sum = 0.0;

	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			vec2 offset = texel * vec2(float(x), float(y));
			vec2 sample_uv = clamp(UV + offset, vec2(0.001), vec2(0.999));
			float dist = float(x * x + y * y);
			float weight = exp(-dist * 0.35);
			color += texture(source_tex, sample_uv) * weight;
			weight_sum += weight;
		}
	}

	COLOR = color / weight_sum;
}
