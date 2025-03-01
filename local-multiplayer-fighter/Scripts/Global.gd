extends Node

@export var game_mode : String = ""

var keybindings : Dictionary = {
	"Player1" : {
		"left" : "move_left_p1",
		"right" : "move_right_p1",
		"jump" : "jump_p1",
		"fire" : "shoot_p1"
	},
	"Player2": {
		"left" : "move_left_p2",
		"right" : "move_right_p2",
		"jump" : "jump_p2",
		"fire" : "shoot_p2"
	}
}
