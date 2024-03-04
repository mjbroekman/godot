extends Area3D

var scene_name : String = "Level"
var next_scene : int = 1
var next_scene_file : String

func _ready():
	next_scene += 1
	next_scene_file = str(scene_name,next_scene,".tscn")
	print(str("Next Level is: ",next_scene_file))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print(str("Switching to ",next_scene_file))
		get_tree().change_scene_to_file(next_scene_file)
