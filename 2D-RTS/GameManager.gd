extends Node2D

var selected_unit : CharacterBody2D
var player_units : Array[CharacterBody2D]
var enemy_units : Array[CharacterBody2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_select_unit()
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_try_command_unit()


func _get_selected_unit():
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	
	query.position = get_global_mouse_position()
	
	var intersection = space.intersect_point(query, 1)

	if !intersection.is_empty():
		return intersection[0].collider
	
	return null


func _try_select_unit():
	var unit = _get_selected_unit()
	print(unit)
	if unit != null and unit.is_player:
		_select_unit(unit)
	else:
		_unselect_unit()


func _select_unit(unit):
	_unselect_unit()
	selected_unit = unit
	selected_unit.toggle_selection_visual(true)


func _unselect_unit():
	if selected_unit != null and selected_unit.is_player:
		selected_unit.toggle_selection_visual(false)

	selected_unit = null


func _try_command_unit():
	if selected_unit == null:
		return
	
	var target = _get_selected_unit()
	if target != null and target.is_player == false:
		selected_unit.set_target(target)
	else:
		selected_unit.move_to_location(get_global_mouse_position())

