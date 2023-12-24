extends Node

@export var player_char : Node
@export var enemy_char : Node
var cur_char : Character

@export var next_turn_delay : float = 1.0

var game_over : bool = false
var characters : Array = [
							"res://Sprites/Boar.png",
							"res://Sprites/Dragon.png",
							"res://Sprites/Reptile.png",
							"res://Sprites/Snake.png"
						 ]

signal character_begin_turn(character)
signal character_end_turn(character)

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.5).timeout
	begin_next_turn()


func begin_next_turn():
	if cur_char == player_char:
		cur_char = enemy_char
	else:
		cur_char = player_char

	emit_signal("character_begin_turn", cur_char)


func end_cur_turn():
	await get_tree().create_timer(next_turn_delay).timeout
	
	if game_over == false:
		begin_next_turn()

	emit_signal("character_end_turn", cur_char)


func character_died(char):
	game_over = true
	if char.is_player == true:
		print("Game Over")
	else:
		print("YOU WIN!")


#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
