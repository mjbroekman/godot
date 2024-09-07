shader_type canvas_item;

uniform vec3 custom_color:source_color; // uniform allows you to access it in the inspector and in GDscript
uniform float custom_alpha: hint_range(0.0,1.0);

void fragment() {
	vec3 color = vec3(0.5,0.3,0.9);
	float alpha = 0.3;
	int test = 1;
	// COLOR.rgb = color;
	// COLOR.a = float(test) * alpha;
	COLOR.rgb = custom_color;
	COLOR.a = custom_alpha;
}
