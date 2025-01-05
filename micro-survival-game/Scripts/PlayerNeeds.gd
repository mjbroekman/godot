extends Node3D

var health : Need
var hunger : Need
var thirst : Need
var tired  : Need

@export var no_hunger_health_decay : float = 0.1
@export var no_thirst_health_decay : float = 0.5
@export var health_regen_sleeping : float = 0.05

var player : CharacterBody3D

func _ready():
	health = get_node("Health")
	hunger = get_node("Hunger")
	thirst = get_node("Thirst")
	tired = get_node("Sleep")
	player = get_parent()

	health.cur_value = health.start_val
	hunger.cur_value = hunger.start_val
	thirst.cur_value = thirst.start_val
	tired.cur_value = tired.start_val

func eat(amount):
	hunger.add(amount)

func rest(amount):
	tired.decay(amount)
	health.add(health_regen_sleeping * amount)

func drink(amount):
	thirst.add(amount)

func update_needs(delta):
	hunger.decay(delta)
	thirst.decay(delta)

	if player.is_sleeping:
		rest(delta)
		if tired.cur_value < 1:
			player.is_sleeping = false
	else:
		tired.regen(delta)
	
	if hunger.cur_value <= 0:
		print("Hunger depleted. Losing health...")
		health.subtract(no_hunger_health_decay * delta)
		thirst.decay(delta)
		tired.regen(no_hunger_health_decay)
	
	if thirst.cur_value <= 0:
		print("Thirst depleted. Losing health...")
		health.subtract(no_thirst_health_decay * delta)
		hunger.decay(delta)
		tired.add(no_thirst_health_decay)
	
	if health.cur_value <= 0:
		print("Health depleted. Game over!")
		get_tree().quit()
