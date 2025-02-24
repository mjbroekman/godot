extends Area2D

@export var speed : int = 550
@export var duration : float = 1
var proj_dir : int = 1

func _ready():
	
	pass

func _process(delta):
	# proj_dir = -1 to move left
	#          =  1 to move right
	position.x += delta * speed * proj_dir

	if position.x < 0:
		queue_free()
	if position.x > get_viewport_rect().size.x:
		queue_free()
