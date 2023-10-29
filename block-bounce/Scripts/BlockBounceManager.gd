extends Node2D

# Always give yourself an RNG
var rng = RandomNumberGenerator.new()

# Set some basic vars
@export var max_force : float = 100.0
@export var max_damp : float = 3.0
@export var game_drag : float = 0.1
@export var game_force : float = 0.1
@export var max_crates : int = 30
@export var max_mass : float = 100.0
@export var base_scale : float = 50.0

var crate_file : PackedScene = load("res://Crate.tscn")
var canvas_transform
var min_position
var max_position
var view_size
var score
var player_mass
var crate_mass

# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	player_mass = rng.randf_range(25.0,max_mass)
	var num_crates = rng.randi_range(5,max_crates)

	canvas_transform = get_canvas_transform()
	min_position = -canvas_transform.get_origin() / canvas_transform.get_scale()
	view_size = get_viewport_rect().size / canvas_transform.get_scale()
	max_position = min_position + view_size

	game_drag = rng.randf_range(1.0,max_damp)
	print("Game Drag = %f" % game_drag)
	game_force = rng.randf_range(max_force * 0.1, max_force * 1.1) * player_mass
	print("Game Force = %f" % game_force)
	
	scatter_crates(num_crates)


func scatter_crates(num_crates):
	var count : int = 0
	while count < num_crates:
		crate_mass = rng.randf_range(25.0,player_mass * 1.5)
		var new_crate = crate_file.instantiate()
		add_child(new_crate)
		new_crate.add_to_group("Crates")
		count += 1


func increase_score(amount):
	score += amount
	var num_crates = get_tree().get_nodes_in_group("Crates").size() - 1
	print("Crates remaining = %d" % num_crates)
	print("Score: %d" % score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
