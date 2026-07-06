shader_type canvas_item;

uniform float shader_time;

void fragment() {
	vec2 uv = UV;
	float aspect = 288.0 / 138.0;
	vec3 bg = vec3(0.098);
	vec3 color = bg;
	
	for (int i = 0; i < 15; i ++) {
		float fi = float(i);
		vec2 firefly_pos = vec2(
			0.5 + 0.45 * sin(shader_time * 0.2 + fi * 1.234),
			0.5 + 0.45 * cos(shader_time * 0.15 + fi * 2.345)
		);
		
		vec3 firefly_color = vec3(
			0.6 + 0.4 * sin(fi * 3.456),
			0.6 + 0.4 * sin(fi * 4.567),
			0.2 + 0.2 * sin(fi * 5.678)
		);
		
		vec2 diff = uv - firefly_pos;
		diff.x *= aspect;
		float dist = length(diff);
		float glow = pow(max(0.0, 1.0 - dist / 0.04), 3.0);
		float pulse = 0.5 + 0.5 * sin(shader_time * (1.0 + fi * 0.3) + fi * 6.789);
		color += glow * pulse * firefly_color;
		float total_glow = color.r + color.g + color.b - 0.098 * 3.0;
		COLOR = vec4(color, clamp(total_glow * 3.0, 0.0, 1.0));
	}
	
	//COLOR = vec4(color, 1.0);
}