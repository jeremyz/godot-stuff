shader_type canvas_item;

uniform sampler2D noise : repeat_enable; // and seamless
uniform float offset : hint_range(0, 0.5) = 0.2;

void fragment() {
	vec4 noise_tex = texture(noise, UV + TIME * 0.1);
	// recentered horizontal offset to the left
	COLOR = texture(TEXTURE,
		vec2(UV.x + noise_tex.r * offset - offset / 2.0, UV.y));
	//COLOR = noise_tex;
}