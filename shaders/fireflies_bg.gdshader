shader_type canvas_item;

uniform float shader_time;
uniform float aspect = 2.087;

const int FIREFLY_COUNT = 25;
const float RADIUS = 0.04;

float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	vec3 color = vec3(0.098);

	for (int i = 0; i < FIREFLY_COUNT; i++) {
		float fi = float(i);

		vec2 firefly_pos = vec2(
			0.5 + 0.45 * sin(shader_time * 0.2 + fi * 1.234),
			0.5 + 0.45 * cos(shader_time * 0.15 + fi * 2.345)
		);

		vec2 diff = UV - firefly_pos;
		diff.x *= aspect;
		float dist_sq = dot(diff, diff);
		if (dist_sq >= RADIUS * RADIUS) {
			continue; // almost every pixel is nowhere near this firefly
		}

		float interval = 1.5 + hash(fi * 17.13) * 3.5;
		float cycle = floor(shader_time / interval);
		float cycle_time = mod(shader_time, interval);

		float flash_duration = mix(0.45, 0.9, hash(fi * 47.3 + cycle * 19.7));
		// start anywhere that still lets the flash finish before the cycle ends
		float flash_start = hash(fi * 31.7 + cycle * 13.1) * (interval - flash_duration);

		float fade_in = smoothstep(flash_start, flash_start + 0.2, cycle_time);
		float fade_out = 1.0 - smoothstep(
			flash_start + flash_duration - 0.3,
			flash_start + flash_duration,
			cycle_time
		);
		float pulse = fade_in * fade_out;

		float t = 1.0 - sqrt(dist_sq) / RADIUS;
		float glow = t * t;

		vec3 firefly_color = vec3(
			0.6 + 0.4 * sin(fi * 3.456),
			0.6 + 0.4 * sin(fi * 4.567),
			0.2 + 0.2 * sin(fi * 5.678)
		);

		color += glow * pulse * firefly_color;
	}

	COLOR = vec4(color, 1.0);
}