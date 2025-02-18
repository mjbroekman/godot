extends CharacterBody2D

@export var move_speed : float = 600.0
@export var jump_force : float = 1000.0
@export var gravity : float = 2800.0
var char_dir : float = 0.0
var player : String = ""
var controls : Dictionary

func _ready():
	if Global.keybindings.has(name):
		print("Using keybindings for " + name)
		player = name
	
	if name == "Player":
		print("Defaulting to controls for player 1")
		player = "Player1"
	
	if name == "":
		print("Error... Player node name not discoverable. Exiting...")
		get_tree().quit()

	controls = Global.keybindings[player]


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		get_node("PlayerSprite").play("Jump")

	# Handle jump.
	if Input.is_action_just_pressed(controls["jump"]) and is_on_floor():
		velocity.y -= jump_force

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	char_dir = Input.get_axis(controls["left"], controls["right"])
	if char_dir > 0:
		get_node("PlayerSprite").flip_h = false
	if char_dir < 0:
		get_node("PlayerSprite").flip_h = true

	if char_dir:
		velocity.x = char_dir * move_speed
		get_node("PlayerSprite").play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		get_node("PlayerSprite").play("Idle")

	move_and_slide()
