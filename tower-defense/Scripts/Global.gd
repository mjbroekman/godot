extends Node

@export var start_health : int = 100
@export var start_money : int = 750
@export var start_wave : int = 0

var enemies_alive : int = 0

var wave : int
var health : int
var money : int

func reset() -> void:
	health = start_health
	money = start_money
	wave = start_wave
	enemies_alive = 0


func update_money(amount : int) -> void:
	money += amount
	print("You now have " + str(Global.money) + " pieces.")


# Called when the node enters the scene tree for the first time.
func _ready():
	reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
