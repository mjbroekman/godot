extends Area2D

var rng = RandomNumberGenerator.new()
var rand_scale : float = 0.0

func _ready():
	rand_scale = rng.randf_range(0.25, 2.0)
	self.scale.x = rand_scale
	self.scale.y = rand_scale

func _on_body_entered(body):
	body.scale.x *= rand_scale
	body.scale.y *= rand_scale

	queue_free()
