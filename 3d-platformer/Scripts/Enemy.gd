extends Area3D

var move_speed : float = 2.0
var move_direction : Vector3

var start_pos : Vector3
var target_pos : Vector3

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	move_direction = Vector3(0.0,rng.randf_range(1.0,4.0),0.0)
	start_pos = global_position
	target_pos = start_pos + move_direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = global_position.move_toward(target_pos,move_speed * delta)
	
	if global_position == target_pos:
		target_pos = start_pos
	
	if global_position == start_pos:
		target_pos = start_pos + move_direction


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.game_over()
