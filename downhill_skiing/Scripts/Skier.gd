extends RigidBody3D

@export var move_speed : float = 0.2

## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if Input.is_key_pressed(KEY_LEFT):
		linear_velocity.x -= move_speed
	
	if Input.is_key_pressed(KEY_RIGHT):
		linear_velocity.x += move_speed

	if delta > 0:
		pass

func _on_body_entered(body):
	if body.is_in_group("Tree"):
		get_tree().reload_current_scene()
