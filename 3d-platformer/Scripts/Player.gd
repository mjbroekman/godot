extends CharacterBody3D

var move_speed : float = 4.0
var jump_force : float = 8.0
var gravity : float = 20.0

var facing_angle : float

@onready var model : MeshInstance3D = get_node("Model")

func _physics_process(delta):
	# Create a Vector2 from our right/left/backward/forward movement
	var input = Input.get_vector("move_right","move_left","move_backward","move_forward")
	# Convert our Vector2 (left/right = .x, forward/back = .y) input into a useful Vector3 (left/right, up/down, forward/back)
	var direction = Vector3(input.x,0,input.y)

	# velocity is defined in CharacterBody3D
	velocity = direction * move_speed
	move_and_slide()
