shader_type canvas_item;
uniform float time_scale = 0.3;
void fragment() {
	float t = TIME * time_scale;
	vec2 uv = UV;
	float r = 0.05 + 0.03 * sin(t + uv.x * 3.0);
	float g = 0.05 + 0.02 * cos(t * 0.7 + uv.y * 2.5);
	float b = 0.08 + 0.03 * sin(t * 1.3 + uv.x + uv.y);
	COLOR = vec4(r, g, b, 1.0);
}
