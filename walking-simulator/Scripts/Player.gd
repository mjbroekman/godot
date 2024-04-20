extends CharacterBody3D
class_name PlayerController

@export_group("Movement")
@export var walk_speed : float = 5.0
@export var run_speed : float = 15.0
@export var acceleration : float = 15.0
@export var braking_speed : float = 10.0
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
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y += jump_force
	
	# Re-orient movement directions to the orientation of our player object (transform)
	var move_input = Input.get_vector("move_left","move_right","move_forward", "move_back")
	var move_direction = (transform.basis * Vector3(move_input.x,0,move_input.y)).normalized()

	is_running = Input.is_action_pressed("move_sprint")

	var target_speed = walk_speed

	if is_running:
		target_speed = run_speed
		# get the dot product between our facing (transform) and move direction
		var run_dot = -move_direction.dot(transform.basis.z)
		# clamp to 0 -> 1 instead of -1 -> 1
		run_dot = clamp(run_dot,0,1)
		move_direction *= run_dot

	var current_smoothing = acceleration
	if not is_on_floor:
		current_smoothing = air_accel
	elif not move_direction:
		current_smoothing = braking_speed

	var target_velocity = move_direction * target_speed

	velocity.x = lerp(velocity.x,target_velocity.x,current_smoothing * delta)
	velocity.z = lerp(move_direction.z,target_velocity.z,current_smoothing * delta)

	# Camera Look
	self.rotate_y(-camera_look_input.x * look_sensitivty)
	camera.rotate_x(-camera_look_input.y * look_sensitivty)

	# clamp() uses radians ... 1.5 == 90degrees
	camera.rotation.x = clamp(camera.rotation.x,-1.5,1.4)

	# Reset camera_look_input after using all its parts
	camera_look_input = Vector2.ZERO
	# move and sliiiiide
	move_and_slide()

	# Press escape to toggle mouse visibility (don't keep in production)
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_look_input = event.relative


