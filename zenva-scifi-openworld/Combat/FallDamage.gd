extends Node

@onready var controller : CharacterBody3D = get_parent()
@onready var health : Health = get_parent().get_node("Health")

@export var min_damage_velocity : float = -10
@export var damage_velocity_multiplier : float = 1.2

var on_floor_last_frame : bool = true
var y_velocity_last_frame : float

func _process(delta):
	if controller.is_on_floor() and !on_floor_last_frame and y_velocity_last_frame < min_damage_velocity:
		calculate_damage()
	
	on_floor_last_frame = controller.is_on_floor()
	y_velocity_last_frame = controller.velocity.y

func calculate_damage ():
	var damage = abs(y_velocity_last_frame) * damage_velocity_multiplier
	health.take_damage(damage)
