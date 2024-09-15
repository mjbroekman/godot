shader_type spatial;

uniform sampler2D test_texture;
uniform sampler2D test_texture2;
uniform float progress : hint_range(0.0,1.0) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Using a gradient2d texture, will cause an obvious hard border where the gradient starts/ends
	// Sphere/cylinder meshes have a hard borders that need to be accounted for.
	// Sphere border is (+z, x=0)
	// Cylinder border is (+z, x+0) AND at the flat ends
	//ALBEDO = texture(test_texture, UV).rgb;
	ALBEDO = texture(test_texture2, UV).rgb;
	ALPHA = step(progress,texture(test_texture2,UV).r);
}
