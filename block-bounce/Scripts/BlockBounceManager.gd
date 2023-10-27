extends Node2D

# Always give yourself an RNG
var rng = RandomNumberGenerator.new()

# Set some basic vars
@export var max_force : float = 1000.0
@export var max_damp : float = 3.0
@export var game_drag : float = 0.1
@export var game_force : float = 0.1
var canvas_transform
var min_position
var view_size
var max_position

# Called when the node enters the scene tree for the first time.
func _ready():
	canvas_transform = get_canvas_transform()
	min_position = -canvas_transform.get_origin() / canvas_transform.get_scale()
	view_size = get_viewport_rect().size / canvas_transform.get_scale()
	max_position = min_position + view_size

	print(min_position)
	print(max_position)
	print(view_size)
	game_drag = rng.randf_range(1.0,max_damp)
	print("Game Drag = %f" % game_drag)
	game_force = rng.randf_range(max_force * 0.1, max_force * 1.1)
	print("Game Force = %f" % game_force)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
