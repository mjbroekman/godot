class_name State
extends Node

var active : bool
var state_machine : StateMachine
var controller : AIController

@export_node_path("AIController") var controller_path : NodePath


func initialize():
	state_machine = get_parent()
	controller = get_node(controller_path)

func enter():
	active = true

func exit():
	active = false

func update(delta):
	pass

func physics_update(delta):
	pass

func navigation_complete():
	pass

func random_offset() -> Vector3:
	var offset = Vector3(randf_range(-1,1), 0, randf_range(-1,1))
	return offset.normalized()

