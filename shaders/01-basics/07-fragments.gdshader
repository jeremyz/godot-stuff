shader_type canvas_item;

uniform float zoom_factor : hint_range(0.0, 5.0) = 2.5;

void zoom(inout vec4 c, in vec2 uv, in sampler2D tex, in float zoom) {
	c = texture(tex, uv * zoom); // last right and bottom pixel raws are repeated
	//c = uv.y > 0.5 ? vec4(0.5, 0.5, 0.0, 1.0) : c;
	//c = uv.x > 0.5 ? vec4(0.5, 0.0, 0.5, 1.0) : c;
}

void columns(inout vec3 c, in vec2 uv, in sampler2D tex, in float cols, in float offset) {
	vec2 tiled_uv = mod(uv * cols + offset, 1.0); // manually repeats
	c = texture(tex, tiled_uv).rgb;
}

void fragment() {
	float dt = mod(TIME, 5);
	if (dt < 2.0) {
		zoom(COLOR, UV, TEXTURE, zoom_factor);
	} else if (dt < 3.0) {
		columns(COLOR.rgb, UV, TEXTURE, 4, 0.0);
	} else {
		columns(COLOR.rgb, UV, TEXTURE, 4, TIME);
	}
}