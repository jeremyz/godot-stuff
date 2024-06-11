shader_type canvas_item;

uniform sampler2D noise;
uniform float threshold : hint_range(0, 1) = 0.5;

void fragment() {
	vec4 noise_tex = texture(noise, UV);
	// noise_tex.r >= threshold (white) => alpha = 1 (visible)
	COLOR = vec4(COLOR.rgb, COLOR.a * step(threshold, noise_tex.r));
	//COLOR = noise_tex;
}