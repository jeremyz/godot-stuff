shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform sampler2D gradient;
//uniform float hp: hint_range(0, 1);

void explode(inout vec2 v, float f) {
	float scale = 1.0 + smoothstep(0.5, 1.0, f);
	v *= scale;
}

void damage(inout vec4 c, vec2 uv, float f) {
	float n_r = texture(noise, uv).r;
	float gx = uv.y + n_r + mix(-2.0, 1.0, f); // [ UV.y + n_r - 2.0 ; UV.x + n_r + 1.0] => [<= 0.0 ; >=1.0]
	vec4 grad_tex = texture(gradient, vec2(gx, 0)); // read gradient from left to right
	float mix_ratio = clamp(gx, 0, 1); // more gradient then original texture
	c = vec4(mix(c.rgb, grad_tex.rgb, mix_ratio), min(c.a, grad_tex.a));
}

void vertex() {
	float f = mod(TIME * 0.5, 1.0);
	explode(VERTEX, f);
}

void fragment() {
	float f = mod(TIME * 0.5, 1.0);
	damage(COLOR, UV, f);
}