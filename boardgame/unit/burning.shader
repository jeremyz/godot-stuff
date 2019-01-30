// shamelessly taken from : https://www.youtube.com/watch?v=NjNxMq7H6tg
// itself inspired by : https://www.shadertoy.com/view/ltV3RG and http://glslsandbox.com/e#35642.0

shader_type canvas_item;

uniform float time;

float Hash( vec2 p) {
    vec3 p2 = vec3(p.xy, 1.0);
    return fract(sin(dot(p2, vec3(37.1, 61.7, 12.4))) * 3.5);
}

float noise( vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f *= f * (vec2(3.0) - 2.0 * f);
    return mix(mix(Hash(i), Hash(i + vec2(1.0, 0.0)) ,f.x),
        mix(Hash(i + vec2(0.0, 1.0)), Hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    v += noise(p * 1.0) * .5;
    // v += noise(p * 2.0) * .25;
    // v += noise(p * 4.0) * .125;
    // v += noise(p * 4.0) * .0625;
    return v;
}

void fragment() {
	vec2 uv = UV;
	vec4 src = texture(TEXTURE, uv);
	vec4 col = src;
	uv.x -= 1.5;
	float ctime = mod(time * 0.5, 2.5);
	float d = uv.x + uv.y * 0.5 + 0.5 * fbm(uv * 15.1) + ctime * 1.3;
	// black
	if (d > 0.35) { col.rgb = clamp(col.rgb - vec3((d - 0.35) * 10.0), 0.0, 1.0); }
	if (d > 0.47) { // flames
	    if (d < 0.5 ) { col.rgb += (d - 0.4) * 15.15 * (0.0 + noise(100.0 * uv + vec2(-ctime * 2.0, 0.0))) * vec3(1.5, 0.5, 0.0); }
	    else { col = vec4(0,0,0,0); }
	}
	COLOR = col;
}
