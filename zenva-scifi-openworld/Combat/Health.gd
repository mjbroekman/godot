class_name Health
extends Node

signal on_change (current : int, max : int)
signal on_take_damage ()
signal on_die ()

enum PostDeath {DestroyNode, RestartScene}

var current : int
@export var max : int = 100

@export var post_death_action : PostDeath
@export var drop_on_death : PackedScene

func _ready():
	current = max

func take_damage (amount : int):
	current -= amount
	on_change.emit(current, max)
	on_take_damage.emit()
	
	if current <= 0:
		die()

func die ():
	on_die.emit()
	
	if drop_on_death != null:
		var drop = drop_on_death.instantiate()
		get_node("/root/").add_child(drop)
		drop.position = get_parent().position + Vector3(0, 0.5, 0)
	
	if post_death_action == PostDeath.DestroyNode:
		get_parent().queue_free()
	elif post_death_action == PostDeath.RestartScene:
		get_tree().reload_current_scene()

func heal (amount : int):
	current += amount
	
	if current > max:
		current = max
	
	on_change.emit(current, max)
