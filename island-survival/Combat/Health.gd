class_name Health
extends Node

signal on_change (cur_health : int, max_health : int)
signal on_take_damage ()
signal on_die ()

enum PostDeath {DestroyNode, RestartScene}

var cur_health : int
@export var max_health : int = 100

@export var post_death_action : PostDeath
@export var drop_on_death : PackedScene

func _ready():
	cur_health = max_health

func take_damage (amount : int):
	cur_health -= amount
	on_change.emit(cur_health, max_health)
	on_take_damage.emit()
	
	if cur_health <= 0:
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
	cur_health += amount
	
	if cur_health > max_health:
		cur_health = max_health
	
	on_change.emit(cur_health, max_health)
