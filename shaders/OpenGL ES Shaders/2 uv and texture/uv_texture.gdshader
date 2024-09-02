shader_type canvas_item;

uniform float offset: hint_range(0.0,1.0) = 0.0;
uniform sampler2D gradient_texture;

// Funky rainbow sheen effect
//void fragment() {
	//COLOR.a = abs(offset - ((UV.x + UV.y) / 2.0));
	//COLOR.r = UV.x;
	//COLOR.g = UV.y;
//}

void fragment() {
	vec4 gradient_color = texture(gradient_texture, UV);
	vec4 color = texture(TEXTURE, UV);
	float original_alpha = color.a;

	COLOR.a = original_alpha * (((UV.x + UV.y) / 2.0) - offset);
	COLOR.rgb = gradient_color.rgb + color.rgb;

}