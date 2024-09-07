shader_type canvas_item;

uniform float progress : hint_range(0.0,1.0);

void fragment() {
	// If-statement example
	//if (UV.x >= 0.5) {
		//COLOR.a = 1.0;
	//} else {
		//COLOR.a = 0.0;
	//}
	
	// Ternary example
	// COLOR.a = ( UV.x >= 0.5 ) ? 1.0 : 0.0;
	
	// CORRECT way to do this using step()
	COLOR.a = step(0.5,UV.x);

	// Diagonal slice
	// COLOR.a = (UV.x > UV.y) ? 1.0 : ((UV.x == UV.y) ? 0.5 : 0.0);
	
	// Complete transparent diagonal top-left -> bottom-right
	// COLOR.a = abs(UV.x - UV.y);
}
