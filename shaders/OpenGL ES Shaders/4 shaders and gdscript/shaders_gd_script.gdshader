shader_type canvas_item;

uniform float progress : hint_range(0.0,1.0) = 0.0;

void fragment() {
	COLOR.a = 1.0 - step(progress,UV.x);
}
