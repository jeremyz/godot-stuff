// based on https://www.shadertoy.com/view/WdKSzD

shader_type canvas_item;

uniform float time;
uniform bool flip_left;
uniform float flip_duration;
uniform float cylinder_ratio;
uniform vec2 cylinder_direction;
uniform vec2 rect;
uniform sampler2D current_page;
uniform sampler2D next_page;

void fragment() {
	if (time > flip_duration) {
		COLOR = texture(next_page, UV);
	} else {
		vec2 pt = UV * rect;
		float R = cylinder_ratio * rect.x; 				// cylinder radius
		float s = 1.5 * rect.x / flip_duration; 		// speed (1.5 width to be sure to leave the page)
		float da = fract(time / flip_duration);			// animation fraction
		vec2 u = normalize(cylinder_direction);			// cylinder direction
		vec2 o = vec2(da * flip_duration * s, 0.0);		// cylinder position
		if (flip_left) o.x = rect.x - o.x;
		float d = dot(pt - o, u);						// distance to cylinder
		vec2 h = pt - u * d;							// projection
		bool neg = d < 0.0;								// left of the cylinder
		if (flip_left) neg = !neg;
		bool onCylinder = abs(d) < R;					// is on cylinder
		vec4 color;
		if (!onCylinder) {
			if (neg) {
				//color = vec4(1,1,0,1);
				color = mix(0.1, 1.0, da) * texture(next_page, UV);		// next page
			} else {
				//color = vec4(1,0,0,1);
				color = texture(current_page, UV);						// current page
			}
		} else {
			float pi = flip_left ? -3.141592653 : 3.141592653;
			float angle = asin(d / R);
			float a0 = pi + angle;
			float a = neg ? -angle : (pi + angle);
			float l = R * a;											// length of arc
			vec2 p = h - u * l;											// unwrapped point from cylinder to plane
			bool outside = any(lessThan(p, vec2(0.0))) || any(greaterThan(p, rect));
			//color = (outside ? vec4(1.0,0.5,0.0,1) : vec4(00,0,1,1));
			color = texture(current_page, (outside ? UV : p / rect));	// front and curved front
			l = R * a0;													// length of arc
			p = h - u * l;												// unwrapped point from cylinder to plane
			outside = any(lessThan(p, vec2(0.0))) || any(greaterThan(p, rect));
			if (!outside) {
				//color = vec4(0,1,0,1);
				color = texture(current_page, p / rect);				// curved back
			}
		}
		COLOR = color;
	}
}