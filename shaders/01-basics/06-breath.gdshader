shader_type canvas_item;

uniform float frequency : hint_range(0.0, 5.0) = 4.0;
uniform float magnitude : hint_range(0.0, 0.05) = 0.03;

void breath(inout vec2 v, float f, float m) {
	float breath_anim = sin(TIME * f) * m;
	v *= 1.0 + breath_anim;
}

void vertex(){
	breath(VERTEX, frequency, magnitude);
}