class_name StateMachine
extends Node

@export var default_state : State
@export var min_time_in_state : float = 0.25

var current_state : State
var last_state_change : float = 0
var states : Dictionary = {}

func _ready():
	await get_tree().create_timer(0.5).timeout

	# Initialize all the states we have as children.
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.initialize()
	
	# Set the default state.
	if default_state != null:
		set_state(default_state.name)

func set_state (state_name):
	var state = states.get(state_name)
	
	if (Time.get_unix_time_from_system() - last_state_change) > min_time_in_state:
		if state == null:
			last_state_change = Time.get_unix_time_from_system()
			return
	
		if state == current_state:
			return
	
		if current_state != null:
			current_state.exit()

		print("SET STATE: " + state_name)
	
		last_state_change = Time.get_unix_time_from_system()
		state.enter()
		current_state = state

func _process(delta):
	if current_state != null:
		current_state.update(delta)

func _physics_process(delta):
	if current_state != null:
		current_state.physics_update(delta)

func _on_enemy_navigation_agent_target_reached():
	if current_state != null:
		current_state.navigation_complete()
