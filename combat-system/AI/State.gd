class_name State
extends Node

@export_node_path("AIController") var controller_path : NodePath
var controller : AIController
var active : bool
var state_machine : StateMachine

# Called when the node is initialized.
# Sets up variables, get nodes, etc.
func initialize ():
	state_machine = get_parent()
	controller = get_node(controller_path)

# Called when we enter into the state.
func enter ():
	active = true

# Called when we exit the state.
func exit ():
	active = false

# Called every frame while in the state.
func update (delta):
	pass

# Called every physics update while in the state.
func physics_update (delta):
	pass

# Called when the controller has completed a navigation path.
func navigation_complete ():
	pass

func _random_offset () -> Vector3:
	var offset = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	return offset.normalized()
