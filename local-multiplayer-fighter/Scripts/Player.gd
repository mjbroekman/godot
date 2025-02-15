extends CharacterBody2D

var move_speed : float = 600.0
var jump_force : float = 1000.0
var gravity : float = 2800.0
var char_dir : float = 0.0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump_p1") and is_on_floor():
		velocity.y -= jump_force

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	char_dir = Input.get_axis("move_left_p1", "move_right_p1")
	if char_dir:
		velocity.x = char_dir * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()
