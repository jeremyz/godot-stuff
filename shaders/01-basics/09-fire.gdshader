shader_type canvas_item;

uniform sampler2D noise;
uniform sampler2D fire;
uniform float debug_f : hint_range(0.0, 1.0);
uniform float noise_amplitude : hint_range(0.01, 0.1) = 0.05;
uniform vec4 fire_c_a : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 fire_c_b : source_color = vec4(1.0, 0.2, 0.0, 1.0);

void fragment() {
	vec4 noise_tex = texture(noise, UV);
	vec4 heat_tex = texture(TEXTURE,
		vec2(UV.x + noise_tex.r * noise_amplitude - noise_amplitude / 2.0, UV.y));
	vec4 fire_c = vec4(mix(fire_c_a, fire_c_b, noise_tex.r).rgb, heat_tex.a); // with round borders
	//vec4 fire_c = vec4(texture(fire, vec2(noise_tex.r, 0)).rgb, heat_tex.a); // use fire gradient
	//vec4 fire_c = vec4(texture(fire, vec2(noise_tex.r - 0.2 * UV.y, 0)).rgb, heat_tex.a); // densify the bottom
	//float heat_fire_ratio = noise_tex.x; // ful mix
	//float heat_fire_ratio = UV.y * UV.y; // more fire at the bottom
	//float heat_fire_ratio = step(0.2, UV.y * UV.y * noise_tex.r); // apply noise_tex
	//float heat_fire_ratio = step(noise_tex.r * 1.05, UV.y); // always dense at the bottom
	float heat_fire_ratio = step(noise_tex.r * 1.05, UV.y) * UV.y + 0.1; // blends towards heat when at the top
	//COLOR = noise_tex;
	//COLOR = heat_tex;
	//COLOR = fire_c;
	COLOR = mix(heat_tex, fire_c, heat_fire_ratio);
}