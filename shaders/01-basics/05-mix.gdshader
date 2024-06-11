shader_type canvas_item;

uniform vec3 cola : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 colb : source_color = vec3(0.0, 1.0, 0.0);
uniform sampler2D zebra :repeat_enable;

void fragment() {
	float zebra_tex_r = texture(zebra, UV).r;
	vec3 pix = mix(COLOR.rgb, mix(cola, colb, UV.x * UV.y), UV.y);
	// multiply by COLOR.a to preserve the round border
	COLOR = vec4(pix, (zebra_tex_r + 0.7) * COLOR.a);
	COLOR.gb *= 1.5;
}