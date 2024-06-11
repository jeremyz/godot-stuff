shader_type canvas_item;

uniform sampler2D noise;

void fragment() {
	vec4 noise_tex = texture(noise, UV);
	// noise_tex.r >= 0.2 -> 0.8 (white) => alpha ramp up to 1 (visible)
	COLOR = vec4(COLOR.rgb, COLOR.a * smoothstep(0.2, 0.8, noise_tex.r));
	//COLOR = noise_tex;
}