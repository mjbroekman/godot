shader_type canvas_item;

uniform float offset_x = 0;
uniform float stretch_y = 1.0;
uniform float center_offset = 50.0;

void vertex() {
	// VERTEX = VERTEX + vec2(offset_x,0.0);

	// Wiggle flip animation
	//VERTEX.y *= stretch_y * sin(TIME);
	//VERTEX.x += sin(VERTEX.y) * 5.0;

	// orbit animation
	// counter-clockwise = x += sin ; y += cos
	// clockwise = x += cos ; y += sin
	VERTEX.x += sin(TIME) * center_offset;
	VERTEX.y += cos(TIME) * center_offset;
}
