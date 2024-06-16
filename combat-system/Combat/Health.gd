class_name Health
extends Node

signal on_change (current : int, max_health : int)
signal on_take_damage ()
signal on_die ()

enum PostDeath {DestroyNode, RestartScene}

var current : int   # Current Health
@export var max_health : int = 100 # Maximum Health
@export var post_death_action : PostDeath # What should be done when the object dies
@export var drop_on_death : Array[PackedScene] # What should be dropped when the object dies

# Called when the node enters the scene tree for the first time.
func _ready():
	current = max_health


func take_damage (amount : int):
	current -= amount
	on_change.emit(current, max_health)
	on_take_damage.emit()

	if current <= 0:
		die()


func heal (amount : int):
	current += amount

	if current > max_health:
		current = max_health

	on_change.emit(current, max_health)


func die ():
	on_die.emit()

	# Get and instantiate a random item from the drop list
	if drop_on_death.size() > 0:
		var drop_idx = randi_range(0,drop_on_death.size()-1)
		if drop_on_death[drop_idx] != null:
			var drop = drop_on_death[drop_idx].instantiate()
			get_node("/root/").add_child(drop)
			drop.position = get_parent().position + Vector3(0,0.25,0) # Spawn a bit above the 'floor'

	if post_death_action == PostDeath.DestroyNode:
		get_parent().queue_free()
	
	elif post_death_action == PostDeath.RestartScene:
		get_tree().reload_current_scene()



