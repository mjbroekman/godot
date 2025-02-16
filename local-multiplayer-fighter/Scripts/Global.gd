extends Node

@export var game_mode : String = ""

var keybindings : Dictionary = {
	"Player1" : {
		"up" : "move_up_p1",
		"left" : "move_left_p1",
		"right" : "move_right_p1",
		"jump" : "jump_p1",
		"fire" : "fire_p1"
	},
	"Player2": {
		"up" : "move_up_p2",
		"left" : "move_left_p2",
		"right" : "move_right_p2",
		"jump" : "jump_p2",
		"fire" : "fire_p2"
	}
}
