extends CharacterBody2D

var move_speed : float = 100.0
var jump_force : float = 200.0
var gravity : float = 500.0

var can_double_jump : bool = false
var has_double_jump : bool = false

var score : int = 0
var lives : int = 5

@onready var score_text : Label = get_node("CanvasLayer/ScoreText")

func _physics_process(delta):
	## Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
#
	velocity.x = 0
	if Input.is_action_pressed("ui_left"):
		velocity.x -= move_speed
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += move_speed

	# Handle jumping
	if Input.is_action_just_pressed("ui_jump"):
		if is_on_floor():
			print("Space bar hit while on the ground. Executing regular jump.")
			velocity.y -= jump_force
		elif can_double_jump:
			print("Space bar hit in mid air. Double jump commencing.")
			can_double_jump = false
			velocity.y -= jump_force

	if is_on_floor() and has_double_jump:
		can_double_jump = true

	if global_position.y > 150:
		game_over()
#
	move_and_slide()

func game_over():
	lives -= 1
	get_tree().reload_current_scene()

func add_score(amount):
	score += amount
	score_text.text = str(" Score: ",score)

