shader_type canvas_item;

uniform vec2 center = vec2(0.5);
uniform float ring_outer = 0.35;
uniform float ring_inner = 0.15;
uniform vec3 color : source_color = vec3(1.0);

void fragment() {
	float alpha_outer = 1.0 - step(ring_outer,distance(center,UV));
	float alpha_inner = 1.0 - step(ring_inner,distance(center,UV));
	COLOR.a = alpha_outer - alpha_inner;
	COLOR.rgb = color;
	// I did it with an if-statement (boo) instead of two alpha vars
	//if ( alpha < ring_inner || alpha > ring_outer ) { alpha = 0.0; }
	//else { alpha = 1.0; }

}
