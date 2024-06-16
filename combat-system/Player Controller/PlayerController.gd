class_name PlayerController
extends CharacterBody3D

@export_group("Movement")
@export var max_speed : float = 4.0
@export var acceleration : float = 20.0
@export var braking : float = 20.0
@export var air_acceleration : float = 4.0
@export var jump_force : float = 5.0
@export var gravity_modifier : float = 1.5
@export var max_run_speed : float = 6.0
var is_running : bool = false

@export_group("Camera")
@export var look_sensitivity : float = 0.005
var camera_look_input : Vector2

@onready var camera : Camera3D = get_node("Camera3D")
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

func _ready():
	# Lock the mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	# Movement
	var move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	is_running = Input.is_action_pressed("sprint")
	
	var target_speed = max_speed
	
	if is_running:
		target_speed = max_run_speed
		var run_dot = -move_dir.dot(transform.basis.z)
		run_dot = clamp(run_dot, 0.0, 1.0)
		move_dir *= run_dot
	
	var current_smoothing = acceleration
	
	if not is_on_floor():
		current_smoothing = air_acceleration
	elif not move_dir:
		current_smoothing = braking
	
	var target_vel = move_dir * target_speed
	
	velocity.x = lerp(velocity.x, target_vel.x, current_smoothing * delta)
	velocity.z = lerp(velocity.z, target_vel.z, current_smoothing * delta)
	
	move_and_slide()
	
	# Camera Look
	rotate_y(-camera_look_input.x * look_sensitivity)	
	camera.rotate_x(-camera_look_input.y * look_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	camera_look_input = Vector2.ZERO
	
	# Mouse
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_look_input = event.relative
