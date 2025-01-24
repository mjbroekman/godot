extends CharacterBody2D


###
# Animations
###
@onready var anim : AnimatedSprite2D = get_node("AnimatedSprite2D")

###
# Movement variables
###
# const SPEED = 300.0
# const JUMP_VELOCITY = -400.0

@export var max_speed : int = 8000
@export var acceleration : int = 1000
@export var jump_height : int = 15000
var move_dir : float = 0

@export var friction : float = 0.22
@export var weight : float = 0.35

###
# State Info
###
@export var current_state : String = ""
var is_jumping : bool = false
@export var can_dash : bool = true
@export var max_jumps : int = 3
@export var jump_count : int = 0
@export var has_double_jump : bool = false

func _ready() -> void:
	change_state("Jump")

func _physics_process(delta):
	# Account for gravity.
	if not is_on_floor():
		# Alternate gravity calculation
		var target_velocity : float = min( (velocity.y + acceleration * delta), (max_speed * delta) )
		velocity.y = lerp(velocity.y, target_velocity, 0.6)
		# Original gravity calculation
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#is_jumping = true

	#if Input.is_action_just_pressed("ui_accept") and is_jumping and has_double_jump and not is_on_floor():
		#velocity.y += JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_dir = Input.get_axis("ui_left", "ui_right")

	# Flip the animated sprite
	if move_dir < 0:
		anim.flip_h = false
	elif move_dir > 0:
		anim.flip_h = true

	#if move_dir:
		#velocity.x = move_dir * max_speed * delta
	#else:
		#velocity.x = move_toward(velocity.x, 0, max_speed * delta)

	#if is_on_floor():
		#is_jumping = false

	move_and_slide()

func change_state(new_state_name: String) -> void:
	current_state = new_state_name
	print("Changing state to " + new_state_name)
	var state_to_start = null
	for state in get_node("StateMachine").get_children():
		print("Checking state " + state.name)
		if new_state_name in state.name:
			print("Found " + new_state_name + " state")
			state_to_start = state
		else:
			state.exit_state()
	
	if state_to_start != null:
		state_to_start.start_state()
