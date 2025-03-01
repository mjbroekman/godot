extends Area2D

@export var speed : float = 750.0
@export var duration : float = 1.0
var proj_dir : int

func _ready():
	if proj_dir == 0:
		proj_dir = 1

func _process(delta):
	# proj_dir = -1 to move left
	#          =  1 to move right
	position.x += (delta * speed * proj_dir)
	duration -= delta
	
	if duration < 0:
		queue_free()

	if position.x < 0:
		queue_free()

	if position.x > get_viewport_rect().size.x:
		queue_free()
