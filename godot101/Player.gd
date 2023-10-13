extends CharacterBody2D

var move_speed : float = 100.0

func _ready():
	pass

func _physics_process(delta):
	velocity.x = 0
	velocity.y = 0

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		velocity.x -= 1

	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		velocity.x += 1

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		velocity.y -= 1

	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		velocity.y += 1

	velocity *= move_speed

	move_and_slide()
