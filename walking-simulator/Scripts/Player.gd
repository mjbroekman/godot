extends CharacterBody3D
class_name PlayerController

@export_group("Movement")
@export var walk_speed : float = 4.0
@export var run_speed : float = 8.0
@export var acceleration : float = 20.0
@export var braking_speed : float = 20.0
@export var air_accel : float = 4.0
@export var jump_force : float = 8.0
@export var gravity_mod : float = 1.5 # this is a modifier on the base project gravity
@export var is_running : bool = false

@export_group("Camera")
@export var look_sensitivty : float = 0.005 # sensivity of camera motion
@export var camera_look_input : Vector2

@onready var camera : Camera3D = get_node("PlayerView")
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_mod

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var move_input = Input.get_vector("move_left","move_right","move_forward", "move_back")

	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y += jump_force
	
	# Re-orient movement directions to the orientation of our player object (transform)
	var move_direction = (transform.basis * Vector3(move_input.x,0,move_input.y)).normalized()
	if ! is_running:
		velocity.x = move_direction.x * walk_speed
		velocity.z = move_direction.z * walk_speed
	else:
		velocity.x = move_direction.x * run_speed
		velocity.z = move_direction.z * run_speed

	# Camera Look
	self.rotate_y(-camera_look_input.x * look_sensitivty)
	camera.rotate_x(-camera_look_input.y * look_sensitivty)
	# clamp() uses radians ... 1.5 == 90degrees
	camera.rotation.x = clamp(camera.rotation.x,-1.5,1.4)

	# Reset camera_look_input after using all its parts
	camera_look_input = Vector2.ZERO
	# move and sliiiiide
	move_and_slide()


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_look_input = event.relative


