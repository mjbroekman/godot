class_name StateMachine
extends Node


@export var default_state : State

var current_state : State
var states : Dictionary = {}

func _ready():
	await get_tree().create_timer(0.5).timeout

	for child in get_children():
		if child is State:
			states[child.name] = child
			child.initialize()

	if default_state != null:
		change_state(default_state.name)


func change_state(state_name):
	var new_state = states.get(state_name)

	if new_state == null:
		return

	if new_state == current_state:
		return

	if current_state != null:
		current_state.exit()

	current_state = new_state
	new_state.enter()


func _process(delta):
	if current_state != null:
		current_state.update(delta)


func _physics_process(delta):
	if current_state != null:
		current_state.physics_update(delta)


func _on_navigation_agent_3d_target_reached():
	if current_state != null:
		current_state.navigation_complete()
