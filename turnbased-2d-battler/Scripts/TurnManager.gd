extends Node

@onready var player_char : Node = get_node("/root/BattleScene/Player")
@onready var enemy_char : Node = get_node("/root/BattleScene/Player2")

var cur_char : Character

var next_turn_delay : float = 1.0

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


func character_died(character):
	game_over = true
	if character.is_player == true:
		print("Game Over")
	else:
		print("YOU WIN!")


func _on_combat_action_3_pressed():
	pass # Replace with function body.


func _on_combat_action_4_pressed():
	pass # Replace with function body.