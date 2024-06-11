shader_type canvas_item;

uniform sampler2D anim_graph;
uniform float columns : hint_range(1.0, 5.0, 1.0) = 2.0;
uniform float amplitude : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	float x = mod(TIME, 1.0);
	float easing = texture(anim_graph, vec2(x, 0.0)).r;
	//vec2 tiled_uv = mod(UV * columns + easing * amplitude, 1.0);
	vec2 tiled_uv = mod(vec2(UV.x * columns + easing * amplitude, UV.y * columns), 1.0);
	COLOR = texture(TEXTURE, tiled_uv);
}