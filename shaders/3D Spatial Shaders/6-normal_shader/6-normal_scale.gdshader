shader_type spatial;

// Normal geometry wikipedia: https://en.wikipedia.org/wiki/Normal_(geometry)

// From Godot docs: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html
//render_mode skip_vertex_transform;
//void vertex() {
    //VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    //NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    //BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
    //TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
//}

uniform float scale_distance: hint_range(0.0,1.0) = 1.0;

void vertex() {
	VERTEX += NORMAL * scale_distance;
	COLOR.r = distance(NORMAL * scale_distance,vec3(0.0));
}

void fragment() {
	ALBEDO = vec3(COLOR.r,0.0,0.0);
}
