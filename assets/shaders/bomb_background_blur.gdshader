shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 4.0) = 1.25;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE * blur_strength;
	vec4 color = texture(TEXTURE, UV) * 0.204;
	color += texture(TEXTURE, UV + vec2(px.x, 0.0)) * 0.153;
	color += texture(TEXTURE, UV - vec2(px.x, 0.0)) * 0.153;
	color += texture(TEXTURE, UV + vec2(0.0, px.y)) * 0.153;
	color += texture(TEXTURE, UV - vec2(0.0, px.y)) * 0.153;
	color += texture(TEXTURE, UV + px) * 0.046;
	color += texture(TEXTURE, UV - px) * 0.046;
	color += texture(TEXTURE, UV + vec2(px.x, -px.y)) * 0.046;
	color += texture(TEXTURE, UV + vec2(-px.x, px.y)) * 0.046;
	COLOR = color;
}
