extends CharacterBody3D

var move_speed : float = 4.0
var jump_force : float = 8.0
var gravity : float = 20.0

var facing_angle : float

var score : int

@onready var score_label : Label = get_node("Score")
@onready var model : MeshInstance3D = get_node("Model")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y += jump_force

	if velocity.y < -30.0:
		game_over()

	# Create a Vector2 from our right/left/backward/forward movement
	var input = Input.get_vector("move_right","move_left","move_backward","move_forward")

	# Convert our Vector2 (left/right = .x, forward/back = .y) input into a useful Vector3 (left/right, up/down, forward/back)
	var direction = Vector3(input.x,0,input.y)

	# Set vectors individually
	# velocity is defined in CharacterBody3D
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	move_and_slide()
	
	facing_angle = Vector2(input.y,input.x).angle()
	if input.length() > 0:
		model.rotation.y = lerp_angle(model.rotation.y,facing_angle,0.25)

func game_over():
	get_tree().reload_current_scene()

func add_score(amount):
	score += amount
	score_label.text = str("Score: ",score)
