extends Node

var cloud_scene : PackedScene = preload("res://Scenes/Cloud.tscn")
var cloud_node

@export var base_clouds : int = 3
@export var level_cloud : int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	cloud_node = get_node("Clouds")
	var my_name = self.scene_file_path.get_file().get_basename()

	var num_clouds = base_clouds + (int(my_name.erase(0,5)) * level_cloud)

	print("Adding " + str(num_clouds) + " to level " + my_name)
	for i in num_clouds:
		var cloud_inst = cloud_scene.instantiate()
		cloud_node.add_child(cloud_inst)
