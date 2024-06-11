//#ifdef DEBUG_MODE_ON
const float dot_size = 0.02;

void debug_draw_dots_at_vertices(vec2 uv, inout vec4 c, sampler2D original_texture) {
	vec2 corners[4];
	corners[0] = vec2(0.0, 0.0);
	corners[1] = vec2(1.0, 0.0);
	corners[2] = vec2(1.0, 1.0);
	corners[3] = vec2(0.0, 1.0);
	bool is_near_corner = false;
	vec3 corder_specific_color = vec3(1,1,1);
	for (int i = 0; i < 4; i++) {
		if (distance(uv, corners[i]) < dot_size) {
			is_near_corner = true;
			corder_specific_color = vec3(corners[i], 1);
			break;
		}
	}
	c = is_near_corner ? vec4(corder_specific_color, 1.0) : c;
}
//#endif