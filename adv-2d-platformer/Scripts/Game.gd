extends Node

@export var health : int = 4
@export var starting_health : int = 4
@export var max_health : int = 4
@export var gold : int = 0

func reset_game():
	health = starting_health
	max_health = starting_health
	gold = 0
