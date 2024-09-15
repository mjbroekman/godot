shader_type spatial;

uniform sampler2D noise_texture;

void vertex() {
	VERTEX.y = texture(noise_texture, UV).r;
	COLOR.r = VERTEX.y;
	COLOR.g = VERTEX.y;
}

void fragment() {
	//ALBEDO = texture(noise_texture, UV).rgb;
	ALBEDO = vec3(step(0.5,COLOR.r),step(0.25,COLOR.g),0.0);
}
