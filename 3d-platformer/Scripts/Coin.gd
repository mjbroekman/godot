extends Area3D

var base_speed : float = 5.0
var bob_height : float
var bob_speed : float
var spin_speed : float

var rng = RandomNumberGenerator.new()

@onready var start_y : float = global_position.y
var timer : float = 0.0

var value : int = 1

func _ready():
	bob_height = rng.randf_range(0.0,0.5)
	bob_speed = rng.randf_range(0.5,1.0) * base_speed
	spin_speed = rng.randf_range(0.1,0.4) * base_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(Vector3.UP, spin_speed * delta)

	timer += delta
	var bob = abs(sin(timer * bob_speed))
	global_position.y = start_y + (bob * bob_height)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.add_score(value)
		queue_free()

