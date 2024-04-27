class_name TerrainGeneration
extends Node

@export_category("Mesh Sizing")
@export var mesh : MeshInstance3D
@export var size_depth : float = 200
@export var size_width : float = 200
@export var mesh_resolution : float = 5
@export var max_height : float = 50

@export_category("Noise Mapping")
@export var noise : FastNoiseLite
@export var elevation_curve : Curve

@export_category("Falloff Settings")
@export var falloff_image : Image
@export var use_falloff : bool = true

@export_category("Spawn Settings")
@export var spawnable_objects : Array[SpawnableObject]

@export_category("Water")
@export var water_level : float = 0.28
@export var roughness : float = 0.5

@onready var water : MeshInstance3D = get_node("Water")
@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Generate a random seed. randi() will give us something between -2^32-1 and (2^32 - 1)
	# 
	# Keeping this for reference...
	#     noise.seed = randi_range(0,Time.get_unix_time_from_datetime_string(Time.get_time_string_from_system()))
	#
	noise.seed = randi()
	rng.seed = noise.seed
	print(str("Using seed: ", noise.seed))
	var falloff_texture = preload("res://Procedural Generation/Textures/TerrainFalloff.png")
	falloff_image = falloff_texture.get_image()
	
	# Find spawnable objects in the scene
	for obj in get_children():
		if obj is SpawnableObject:
			spawnable_objects.append(obj)

	generate()

func generate():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size_width,size_depth)
	print(plane_mesh.size)
	plane_mesh.subdivide_depth = size_depth * mesh_resolution
	plane_mesh.subdivide_width = size_width * mesh_resolution
	plane_mesh.material = preload("res://Procedural Generation/Materials/TerrainMaterial.tres")

	var surface = SurfaceTool.new()
	var data = MeshDataTool.new()
	surface.create_from(plane_mesh, 0) # 0 is the surface ID (first surface is 0)

	var array_plane = surface.commit()
	data.create_from_surface(array_plane,0)

	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		var new_y = get_noise_y(vertex.x,vertex.z)
		vertex.y = new_y
		data.set_vertex(i,vertex)

	array_plane.clear_surfaces()

	data.commit_to_surface(array_plane)
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.create_from(array_plane,0)
	surface.generate_normals()

	mesh = MeshInstance3D.new()
	mesh.mesh = surface.commit() # generates the final mesh
	mesh.create_trimesh_collision() # creates colliders
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.add_to_group("NavSource")
	add_child(mesh)
	
	water.position.y = water_level * max_height
	# figure out how to adjust the roughness here
	

	for obj in spawnable_objects:
		spawn_objects(obj)

# Take x and z coords and look up the location in the noise map
func get_noise_y(x, z) -> float:
	var value = noise.get_noise_2d(x,z)  # return a value from -1 to 1
	var remapped_value = (value + 1) / 2.0 # remap from -1 -> 1 to 0 -> 1
	var adjusted_value = elevation_curve.sample(remapped_value)

	var x_percent = (x + (size_width / 2.0)) / size_width
	var z_percent = (z + (size_depth / 2.0)) / size_depth

	var x_pixel = int(x_percent * falloff_image.get_width())
	var y_pixel = int(z_percent * falloff_image.get_height())

	if x_pixel == falloff_image.get_width():
		x_pixel -= 1

	if y_pixel == falloff_image.get_height():
		y_pixel -= 1

	var falloff = falloff_image.get_pixel(x_pixel,y_pixel).r

	if not use_falloff:
		falloff = 1

	return adjusted_value * max_height * falloff

func _get_random_position() -> Vector3:
	var x = rng.randf_range(-size_width / 2, size_width / 2)
	var z = rng.randf_range(-size_depth / 2, size_depth / 2)
	var y = get_noise_y(x, z)
	return Vector3(x, y, z)

func spawn_objects(spawnable : SpawnableObject):
	for i in range(spawnable.spawn_count):
		# initial thought was rng.randi_range(0, spawnable.scenes_to_spawn.size() - 1) but
		# randi() mod spawnable.scenes_to_spawn.size() works fine too
		var idx = rng.randi() % spawnable.scenes_to_spawn.size()
		var obj = spawnable.scenes_to_spawn[idx].instantiate()
		obj.add_to_group("NavSource")
		add_child(obj)

		var pos = _get_random_position()

		if not spawnable.water_ok:
			while pos.y < (water_level * max_height):
				pos = _get_random_position()

		obj.position = pos
		obj.scale = Vector3.ONE * rng.randf_range(spawnable.min_scale,spawnable.max_scale)
		obj.rotation_degrees.y = rng.randf_range(0,360)
