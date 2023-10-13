extends Area3D

# modify to 'chance to pop'
var clicks_to_pop : int = 3
var size_increase : float = 0.2
var score_to_give : int = 1


func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Increase size!")
		
