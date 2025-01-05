extends Node
class_name Need

var cur_value : float
@export var top_value : float
@export var start_val : float
@export var regen_rate : float
@export var decay_rate : float
@export var ui_bar : Node

func _ready():
	ui_bar = get_node("NeedBar")
	if name == "Health":
		start_val = 80.0
		top_value = 100.0
		regen_rate = 0.0
		decay_rate = 0.0
	
	if name == "Hunger":
		start_val = 100.0
		top_value = 100.0
		regen_rate = 0.0
		decay_rate = 0.5

	if name == "Thirst":
		start_val = 100.0
		top_value = 100.0
		regen_rate = 0.0
		decay_rate = 1.0

	if name == "Sleep":
		start_val = 0.0
		top_value = 100.0
		regen_rate = 0.1
		decay_rate = 0.5
	
	cur_value = start_val

	update_ui_bar()


func add(amount):
	cur_value += abs(amount)
	if cur_value > top_value:
		cur_value = top_value

	update_ui_bar()


func subtract(amount):
	cur_value -= abs(amount)
	if cur_value < 0:
		cur_value = 0

	update_ui_bar()


func decay(delta):
	subtract(decay_rate * delta)


func regen(delta):
	add(regen_rate * delta)


func update_ui_bar():
	ui_bar.update_value(cur_value,top_value)
