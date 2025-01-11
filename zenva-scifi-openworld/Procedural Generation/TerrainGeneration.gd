class_name TerrainGeneration
extends Node

var mesh : MeshInstance3D
var size_depth : int = 300
var size_width : int = 300
var mesh_resolution : int = 2
var max_height : float = 70
var use_falloff : bool = true

@export var noise : FastNoiseLite
@export var elevation_curve : Curve
@export var water_level : float = 0.2

var falloff_image : Image

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var spawnable_objects : Array[SpawnableObject]

@onready var water : MeshInstance3D = get_node("Water")
@onready var nav_region : NavigationRegion3D = get_node("NavigationRegion3D")

func _ready():
	# get the spawnable objects
	for i in get_children():
		if i is SpawnableObject:
			spawnable_objects.append(i)
	
	# load the falloff texture
	var falloff_texture = preload("res://Procedural Generation/Textures/TerrainFalloff.png")
	falloff_image = falloff_texture.get_image()
	
	# generate a seed for the noise and RNG
	noise.seed = randi()
	rng.seed = noise.seed
	
	generate()

# this is the main function used in generating our terrain
func generate ():
	# setup the plane mesh data
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size_width, size_depth)
	plane_mesh.subdivide_depth = size_depth * mesh_resolution
	plane_mesh.subdivide_width = size_width * mesh_resolution
	plane_mesh.material = preload("res://Procedural Generation/Materials/TerrainMaterial.tres")
	
	# initialize our tools
	var surface = SurfaceTool.new()
	var data = MeshDataTool.new()
	surface.create_from(plane_mesh, 0)
	
	var array_plane = surface.commit()
	data.create_from_surface(array_plane, 0)
	
	# loop through each vertex and adjust its Y position
	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		
		var y = get_noise_y(vertex.x, vertex.z)
		vertex.y = y
		
		data.set_vertex(i, vertex)
	
	# apply these changes and other boiler-plate settings
	array_plane.clear_surfaces()	
	data.commit_to_surface(array_plane)
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.create_from(array_plane, 0)
	surface.generate_normals()
	
	# create the mesh node
	mesh = MeshInstance3D.new()
	mesh.mesh = surface.commit()
	mesh.create_trimesh_collision()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.add_to_group("NavSource")
	add_child(mesh)
	
	# adjust the water position
	water.position.y = water_level * max_height
	
	# spawn in our objects
	for i in spawnable_objects:
		spawn_objects(i)
	
	# generate the nav mesh
	nav_region.bake_navigation_mesh()
	await nav_region.bake_finished
	
	# ---------------
	# Spawn AI here
	# ---------------

# returns a Y position from the given X and Z
# uses the noise map, elevation curve and falloff
func get_noise_y (x, z) -> float:
	# get the noise value based on the given coordinates
	var value = noise.get_noise_2d(x, z)
	
	# the noise gives us a range of -1.0 to 1.0
	# we want to remap that to a range of 0.0 to 1.0
	var remapped_value = (value + 1) / 2
	
	# sample the elevation curve to adjust that value
	var adjusted_value = elevation_curve.sample(remapped_value)
	
	# convert our X and Z to a range of 0.0 to 1.0
	var x_percent = (x + (size_width / 2)) / size_width
	var z_percent = (z + (size_depth / 2)) / size_depth
	
	# find the X and Y pixel for the coordinate on the falloff texture
	var x_pixel = int(x_percent * falloff_image.get_width())
	var y_pixel = int(z_percent * falloff_image.get_height())
	
	# sample the falloff texture
	var falloff = falloff_image.get_pixel(x_pixel, y_pixel).r
	
	# if we're not using falloff, set that value to 0
	if not use_falloff:
		falloff = 1.0
	
	return adjusted_value * max_height * falloff

# returns a random position on the terrain
func get_random_position () -> Vector3:
	var x = rng.randf_range(-size_width / 2, size_width / 2)
	var z = rng.randf_range(-size_depth / 2, size_depth / 2)
	var y = get_noise_y(x, z)
	return Vector3(x, y, z)

# spawns in the given object
func spawn_objects (spawnable : SpawnableObject):
	for i in range(spawnable.spawn_count):
		var obj = spawnable.scenes_to_spawn[rng.randi() % spawnable.scenes_to_spawn.size()].instantiate()
		obj.add_to_group("NavSource")
		add_child(obj)
		
		var random_pos = get_random_position()
		
		# make sure this object does not spawn below the water line
		while random_pos.y < water_level * max_height:
			random_pos = get_random_position()
		
		obj.position = random_pos
		obj.scale = Vector3.ONE * rng.randf_range(spawnable.min_scale, spawnable.max_scale)
		obj.rotation_degrees.y = rng.randf_range(0, 360)
		
