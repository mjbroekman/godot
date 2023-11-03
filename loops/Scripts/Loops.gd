extends Node2D

@export var spawn_count : int = 200
var star_scene = preload("res://Star.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in spawn_count:
		var new_star = star_scene.instantiate()
		add_child(new_star)
		new_star.add_to_group("Stars")
		new_star.position = Vector2(randi_range(-280,280), randi_range(-150,150))
		var size = randf_range(0.5,2.0)
		new_star.scale = Vector2(size,size)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
