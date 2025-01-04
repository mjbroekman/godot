extends CharacterBody3D

var camera : Camera3D
var head : Node3D

@export_category("Movement")
@export var move_speed : float = 5.0
@export var jump_force : float = 5.0
@export var gravity : float = 9.0

@export_category("Camera")
@export var invert_mouse : bool = true
@export_range(0.1,2,0.1) var look_sens : float = 0.5   # how much should we rotate when looking
@export_range(-10,-85,0.1) var min_x_rot : float = -85.0 # how far down can we rotate the camera
@export_range(10,85,0.1) var max_x_rot : float = 85.0  # how far up can we rotate the camera

var mouse_dir : Vector2

func _ready():
	camera = get_node("Camera3D")
	head = get_node("Head")
	
	remove_child(camera)
	get_node("/root/Main").add_child.call_deferred(camera)


func _input(event):
	if event is InputEventMouseMotion:
		camera.rotation_degrees.x += event.relative.y * ( -look_sens if invert_mouse else look_sens )
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x,min_x_rot,max_x_rot)

		camera.rotation_degrees.y += event.relative.x * ( -look_sens if invert_mouse else look_sens )


func _process(delta):
	camera.position = head.global_position


func _physics_process(delta):
	var keypress = Input.get_vector("move_left","move_right","move_forward","move_back")

	velocity.x = keypress.x * move_speed
	velocity.z = keypress.y * move_speed
	
	move_and_slide()
