// based on https://www.shadertoy.com/view/WdKSzD

shader_type canvas_item;

uniform float time;
uniform vec2 rect;
uniform sampler2D tex1;
uniform sampler2D tex2;

const float r = 0.3;	// applied to width to compute the cylinder radius
const float du = 3.0;	// animation duration

void fragment() {
	if (time < du) {
		vec2 pt = UV * rect;
		float R = r * rect.x; 							// cylinder radius
		float s = 1.5 * rect.x / du; 					// speed (1.5 width to be sure to leave the page)
		float da = fract(time / du);					// animation fraction
		vec2 u = normalize(vec2(5.0, -1.0));			// cylinder direction
		vec2 o = vec2(da * du * s, 0.0);				// cylinder position
		float d = dot(pt - o, u);						// distance to cylinder
		vec2 h = pt - u * d;							// projection
		bool onCylinder = abs(d) < R;					// is on cylinder
		float angle = onCylinder ? asin(d / R) : 0.0;	// 
		bool neg = d < 0.0;
		float a0 = 3.141592653 + angle;
	    float a = onCylinder ? (neg ? -angle : (3.141592653 + angle)) : 0.0;
	    float l = R * a;								// length of arc
	    vec2 p = h - u * l;								// unwrapped point from cylinder to plane
		bool outside = any(lessThan(p, vec2(0.0))) || any(greaterThan(p, rect));
	    bool next = (!onCylinder || outside) && neg;	// is next page
		vec4 color = (next ? mix(0.1, 1.0, da) * texture(tex2, UV) : texture(tex1, (!onCylinder || outside ? UV : p / rect)));
	    l = R * a0;										// length of arc
	    p = h - u * l;									// unwrapped point from cylinder to plane
	    outside = any(lessThan(p, vec2(0.0))) || any(greaterThan(p, rect));
	    color = outside || !onCylinder ? color : texture(tex1, p/ rect);
		COLOR = color;
	} else {
		COLOR = texture(tex2, UV);
	}	
}