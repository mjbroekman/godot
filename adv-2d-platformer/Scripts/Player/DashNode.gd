extends AnimatedSprite2D

var direction
@export var duration : float = 0.5

func _physics_process(_delta):
	if direction < 0:
		flip_h = true
	else:
		flip_h = false
	
	position.x -= direction
	
	var dash_tween = get_tree().create_tween()
	dash_tween.tween_property(self, "modulate:a", 0, duration)
	if modulate.a < 0.01:
		queue_free()
