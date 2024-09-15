shader_type spatial;

// Parameterized offset
//uniform float x_distance = 0.0;
//uniform float y_distance = 0.0;
//uniform float z_distance = 0.0;

void vertex() {
	// Basic offset influence
	// VERTEX += vec3(1.0,0.0,0.0);

	// Parameterized offset
	// VERTEX += vec3(x_distance,y_distance,z_distance);

	// Angle the plane
	//VERTEX.y += VERTEX.x;

	// V-shaped plane ( don't forget to subdivide the mesh! )
	// VERTEX.y += abs(VERTEX.x) - 1.0;

	// Sinusoidal plane
	VERTEX.y += cos(VERTEX.x * 5.0);
}
