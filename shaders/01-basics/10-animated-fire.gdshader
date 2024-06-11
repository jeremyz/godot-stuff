shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform sampler2D fire;
uniform float noise_amplitude : hint_range(0.01, 0.1) = 0.05;

void fragment() {
	float noise_tex_r = texture(noise, vec2(UV.x + TIME * 0.07, UV.y + TIME * 0.25)).r; // seamless && reapeat
	vec4 heat_tex = texture(TEXTURE,
		vec2(UV.x + noise_tex_r * noise_amplitude - noise_amplitude / 2.0, UV.y));
	vec4 fire_c = vec4(texture(fire, vec2(noise_tex_r - 0.2 * UV.y, 0)).rgb, heat_tex.a);
	float heat_fire_ratio = step(noise_tex_r, UV.y) * UV.y + 0.1;
	COLOR = mix(heat_tex, fire_c, heat_fire_ratio);
}