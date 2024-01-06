extends CharacterBody2D

var move_speed : float = 100.0
var jump_force : float = 200.0
var gravity : float = 500.0
var can_double_jump : bool = false
var has_double_jump : bool = false
#
#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#
#
func _physics_process(delta):
	## Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
#
	velocity.x = 0
	if Input.is_key_pressed(KEY_LEFT):
		velocity.x -= move_speed
	
	if Input.is_key_pressed(KEY_RIGHT):
		velocity.x += move_speed

	# Handle jumping
	if Input.is_key_pressed(KEY_SPACE) and ( is_on_floor() or can_double_jump):
		if not is_on_floor():
			can_double_jump = false
		velocity.y -= jump_force
#
	if is_on_floor() and has_double_jump:
		can_double_jump = true

	if global_position.y > 150:
		game_over()
#
	move_and_slide()

func game_over():
	get_tree().reload_current_scene()
