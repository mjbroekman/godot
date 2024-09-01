extends Node

@export var coin : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func spawn_new_coin():
	var new_coin : Area2D = coin.instantiate()

	add_child(new_coin)
	new_coin.position = Vector2(576, 120)

	print("Spawned a new coin")
