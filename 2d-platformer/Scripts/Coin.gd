extends Area2D

var shake_height : float = 5.0
var shake_speed : float = 5.0
var last_chg : float = 0.0
var time_t : float = 2.0

@onready var start_pos_y : float = global_position.y

var value : int = 0

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	value = rng.randi_range(1,5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_t += delta
	var dir = ( sin( time_t * shake_speed ) + 1 ) / 2
	global_position.y = start_pos_y + ( dir * shake_height )


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.add_score(value)
		queue_free()
