// // inspired by : https://www.shadertoy.com/view/4tVGRy and https://www.shadertoy.com/view/llj3Dz

shader_type canvas_item;

//uniform float time = 0.5;
uniform vec2 center = vec2(0.4, 0.3);
uniform float speed = 0.7;
uniform float thikness = 0.04;
uniform float growth = 8.0;
uniform float refraction = 2.8;
uniform float amplitude = 0.015;
uniform float brightness = 0.04;

void fragment()
{
	float time = mod(TIME, 3); // demo
	float ratio = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
	vec2 scaled_uv = (UV - vec2(center.x, 0.0)) / vec2(ratio, 1.0) + vec2(center.x, 0.0);

	float width = thikness + thikness * time * growth;
	float radius = time * speed;
	float dist = distance(scaled_uv, center);

	if (dist >= (radius - width) && dist <= (radius + width)) {
		float diff = (dist - radius) / width;
		float diff_pow = (1.0 - pow(abs(diff), refraction));
		vec2 dir = normalize(scaled_uv - center);
		vec2 tex = UV + (dir * diff * diff_pow * amplitude);
		vec4 color = texture(TEXTURE, tex);
		color += (color * diff_pow * brightness) / (time * dist);
		COLOR = color;
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}
