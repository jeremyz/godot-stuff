// based on https://www.shadertoy.com/view/WdKSzD

shader_type canvas_item;

uniform float time;
uniform vec2 rect;
uniform sampler2D tex1;
uniform sampler2D tex2;

const float r = 0.3;	// applied to width to compute the cylinder radius
const float du = 3.0;	// animation duration

void fragment() {
	if (time > du) {
		COLOR = texture(tex2, UV);
	} else {
		vec2 pt = UV * rect;
		float R = r * rect.x; 							// cylinder radius
		float s = 1.5 * rect.x / du; 					// speed (1.5 width to be sure to leave the page)
		float da = fract(time / du);					// animation fraction
		vec2 u = normalize(vec2(5.0, -1.0));			// cylinder direction
		vec2 o = vec2(da * du * s, 0.0);				// cylinder position
		float d = dot(pt - o, u);						// distance to cylinder
		vec2 h = pt - u * d;							// projection
		bool neg = d < 0.0;								// left of the cylinder
		bool onCylinder = abs(d) < R;					// is on cylinder
		vec4 color;
		if (!onCylinder) {
			if (neg) {
				color = mix(0.1, 1.0, da) * texture(tex2, UV);	// next page
			} else {
				color = texture(tex1, UV);						// current page
			}
		} else {
			float angle = asin(d / R);
			float a0 = 3.141592653 + angle;
			float a = neg ? -angle : (3.141592653 + angle);
			float l = R * a;									// length of arc
			vec2 p = h - u * l;									// unwrapped point from cylinder to plane
			bool outside = any(lessThan(p, vec2(0.0))) || any(greaterThan(p, rect));
			color = texture(tex1, (outside ? UV : p / rect));	// front and curved front
			l = R * a0;											// length of arc
			p = h - u * l;										// unwrapped point from cylinder to plane
			outside = any(lessThan(p, vec2(0.0))) || any(greaterThan(p, rect));
			if (!outside) {
				color = texture(tex1, p / rect);					// curved back
			}
		}
		COLOR = color;
	}
}