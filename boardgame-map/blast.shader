// // inspired by : https://www.shadertoy.com/view/4tVGRy and https://www.shadertoy.com/view/llj3Dz

shader_type canvas_item;

//uniform float time = 0.5;
uniform vec2 center = vec2(0.4, 0.6);
uniform float speed = 0.5;
uniform float thikness = 0.12;
uniform float growth = 0.1;
uniform float refraction = 0.8;
uniform float amplitude = 0.045;
uniform float brightness = 2.0;
uniform float decay = 10.0;

void fragment()
{
	float time = mod(TIME, 3); // demo
	float ratio = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
	vec2 scaled_uv = (UV - vec2(center.x, 0.0)) / vec2(ratio, 1.0) + vec2(center.x, 0.0);

	float width = thikness + (thikness * time * growth);
	float radius = time * speed;
	float dist = distance(scaled_uv, center);

	if (dist >= (radius - width) && dist <= (radius + width)) {
		float diff = abs((dist - radius) / width);
		float diff_pow = (1.0 - pow(diff, refraction));
		float decay_factor = 1.0 / (time * dist  * decay);
		vec2 dir = normalize(scaled_uv - center);
		vec2 tex = UV + (dir * diff * diff_pow * amplitude * decay_factor);
		vec4 color = texture(TEXTURE, tex);
		color += (color * diff_pow * brightness * decay_factor);
		COLOR = color;
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}
