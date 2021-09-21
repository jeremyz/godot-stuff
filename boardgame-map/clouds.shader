// inspired by : https://www.shadertoy.com/view/tlB3zK

shader_type canvas_item;

uniform bool smoke_on = false;
uniform float smoke_speed = 0.002;
uniform float smoke_color = 0.5;
uniform float smoke_transparency = 0.9;
uniform vec2 smoke_direction = vec2(20, 50);

//noise function from iq: https://www.shadertoy.com/view/Msf3WH
vec2 hash( vec2 p )
{
	p = vec2( dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)) );
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise( in vec2 p )
{
	const float K1 = 0.366025404; // (sqrt(3)-1)/2;
	const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2  i = floor(p + (p.x + p.y) * K1);
	vec2  a = p - i + (i.x + i.y) * K2;
	float m = step(a.y, a.x);
	vec2  o = vec2(m, 1.0 - m);
	vec2  b = a - o + K2;
	vec2  c = a - 1.0 + 2.0 * K2;
	vec3  h = max( 0.5-vec3(dot(a, a), dot(b, b), dot(c, c) ), 0.0 );
	vec3  n = h * h * h * h * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
	return dot( n, vec3(70.0) );
}

const mat2 m2 = mat2(vec2(1.6, 1.2), vec2(-1.2, 1.6));

float fbm4(vec2 p)
{
	float amp = 0.5;
	float h = 0.0;
	for (int i = 0; i < 4; i++) {
		float n = noise(p);
		h += amp * n;
		amp *= 0.5;
		p = m2 * p ;
	}
	return  0.5 + 0.5 * h;
}

vec4 clouds(in vec3 sky, in vec2 uv, in float time)
{
	vec3 col = vec3(0.0);
	vec3 smoke_col = vec3(smoke_color);
	vec2 scale = uv * 2.0;
	vec2 turbulence = 0.018 * vec2(noise(vec2(uv.x * 10.0, uv.y *10.0)), noise(vec2(uv.x * 10.0, uv.y * 10.0)));
	scale += turbulence;
	float n1 = fbm4(vec2(scale.x - smoke_direction.x * sin(time * smoke_speed * 2.0), scale.y - smoke_direction.y * sin(time * smoke_speed)));
	col = mix( sky, smoke_col, smoothstep(0.4, smoke_transparency, n1));
	scale = uv * 0.5;
	turbulence = 0.05 * vec2(noise(vec2(uv.x * 2.0, uv.y * 2.1)), noise(vec2(uv.x * 1.5, uv.y * 1.2)));
	scale += turbulence;
	float n2 = fbm4(scale + 20.0 * sin(time * smoke_speed));
	col =  mix( col, smoke_col, smoothstep(0.5, 1.0, n2));
	col = min(col, vec3(1.0));
	return vec4(col, 1.0);
}

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec4 color = texture(TEXTURE, UV);
	if (smoke_on) {
		vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE.xy);
		uv -= 0.5;
		uv.x *= ratio;
		color = clouds(color.xyz, uv, TIME);
	}
	COLOR = color;
}