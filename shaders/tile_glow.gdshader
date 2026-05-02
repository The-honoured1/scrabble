shader_type canvas_item;
uniform vec4 glow_color : source_color = vec4(0.32, 0.72, 0.53, 1.0);
uniform float intensity = 0.6;
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = mix(tex, glow_color, intensity * tex.a);
}
