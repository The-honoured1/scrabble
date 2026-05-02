shader_type canvas_item;
uniform float blur = 0.0015;
void fragment() {
	vec4 c = texture(TEXTURE, UV) * 0.4;
	c += texture(TEXTURE, UV + vec2(blur, 0.0)) * 0.15;
	c += texture(TEXTURE, UV - vec2(blur, 0.0)) * 0.15;
	c += texture(TEXTURE, UV + vec2(0.0, blur)) * 0.15;
	c += texture(TEXTURE, UV - vec2(0.0, blur)) * 0.15;
	COLOR = c;
}
