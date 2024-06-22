extends Node3D

@export var speed : float = 20.0
@export var max_distance : float = 75.0
var start_pos : Vector3 = position


# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(basis.z * speed * delta)
	if position.distance_to(start_pos) > max_distance:
		position = start_pos
