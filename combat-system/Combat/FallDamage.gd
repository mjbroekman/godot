extends Node

@onready var controller : CharacterBody3D = get_parent()
@onready var health : Health = get_parent().get_node("Health")

@export var min_damage_velocity : float = -10.0
@export var damage_velocity_multiplier : float = 1.5

var on_floor_last_frame : bool = true
var y_velocity_last_frame : float = 0.0
var fall_time : float = 0.0
var max_fall_time : float = 2.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Broken over two if-statements for readability
	if controller.is_on_floor() and ! on_floor_last_frame:
		if y_velocity_last_frame <= min_damage_velocity:
			calculate_damage()

	if ! controller.is_on_floor():
		fall_time += delta
		if fall_time > max_fall_time:
			calculate_damage()
	else:
		fall_time = 0.0

	on_floor_last_frame = controller.is_on_floor()
	y_velocity_last_frame = controller.velocity.y
	
func calculate_damage():
	var damage = abs(y_velocity_last_frame) * damage_velocity_multiplier
	health.take_damage(damage)
