= Shaders
These shaders are built during the following Zenva courses:
* Intro to Visual Shaders: https://academy.zenva.com/course/godot-visual-shaders-course/
* Open GL ES Shaders: https://academy.zenva.com/course/godot-opengl-es-shaders-course/
* 3D Spatial Shaders: https://academy.zenva.com/course/godot-3d-spatial-shaders-course/
  * This is a very, very basic introduction to 3d spatial shaders
  * NOTE: ProximityFade only exists in visual shader, in shader code it's a complicated couple of statements

= ProximityFade
```
// ProximityFade:2
    {
        float __depth_tex = texture(depth_tex_frg_2, SCREEN_UV).r;
        vec4 __depth_world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, __depth_tex, 1.0);
        __depth_world_pos.xyz /= __depth_world_pos.w;
        n_out2p0 = clamp(1.0 - smoothstep(__depth_world_pos.z + n_out3p0, __depth_world_pos.z, VERTEX.z), 0.0, 1.0);
    }
```

= Resources
* https://godotshaders.com/
* https://en.wikipedia.org/wiki/Normal_(geometry)
* https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html

