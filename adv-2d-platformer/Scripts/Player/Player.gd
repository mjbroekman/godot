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
@export var can_jump_dash : bool = true
@export var max_jumps : int = 3
@export var jump_count : int = 0
@export var has_double_jump : bool = true
@export var can_double_jump : bool = false

func _ready() -> void:
	change_state("Idle")

func _physics_process(delta):
	if not is_on_floor():
		var target_velocity : float = min( (velocity.y + acceleration * delta), (max_speed * delta) )
		velocity.y = lerp(velocity.y, target_velocity, 0.6)
		#velocity += get_gravity() * delta

	move_player(delta)


func move_player(delta):
	# Get the input direction and handle the movement/deceleration.
	move_dir = Input.get_axis("move_left", "move_right")

	# Flip the animated sprite
	if move_dir < 0:
		anim.flip_h = false
	elif move_dir > 0:
		anim.flip_h = true

	if move_dir > 0:
		var target_velocity : float = min( (velocity.x + acceleration * delta), (max_speed * delta) )
#		velocity.x = move_dir * max_speed * delta
		velocity.x = lerp(velocity.x, target_velocity, weight)
	elif move_dir < 0:
		var target_velocity : float = max( (velocity.x - acceleration * delta), (-max_speed * delta) )
#		velocity.x = move_dir * max_speed * delta
		velocity.x = lerp(velocity.x, target_velocity, weight)
	elif is_on_floor():
		change_state("Idle")

	move_and_slide()


func change_state(new_state_name: String) -> void:
	current_state = new_state_name
	var state_to_start = null
	for state in get_node("StateMachine").get_children():
		if new_state_name in state.name:
			state_to_start = state
		else:
			state.exit_state()
	
	if state_to_start != null:
		state_to_start.start_state()
