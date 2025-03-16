extends Sprite2D

@export var speed : float = 45

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = scale * rng.randf_range(0.5,2.0)
	speed = speed * rng.randf_range(0.75,3.0)
	position = get_start_position()

func get_start_position() -> Vector2:
	var start_y = rng.randf_range(0, get_viewport_rect().size.y * 0.75)
	var start_x = -150
	var start_position = Vector2(start_x, start_y)
	return start_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += speed * delta
	if position.x > (get_viewport_rect().size.x * 1.25):
		position = get_start_position()
