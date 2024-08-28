shader_type canvas_item;

// uniform float progress: hint_range(0.0, 1.0) = 0.0;
uniform vec3 outline_c: source_color = vec3(1.0, 0.0, 0.0);

void fragment() {
	float outer_a = texture(TEXTURE, UV * 0.975 + 0.0125).a;
	// use COLOR.a instead of outer_a for inner outline
	COLOR = mix(COLOR, vec4(outline_c, outer_a), mod(TIME, 1.0) * (1.0 - COLOR.a));
}