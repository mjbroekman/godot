extends Control

var finish_game_screen : ColorRect

func _ready():
	finish_game_screen = get_node("GameFinished")
	finish_game_screen.hide()


func game_finished(winner_name : String) -> void:
	finish_game_screen.show()
	finish_game_screen.get_node("Container/WinnerLabel").text = winner_name + " WINS!"
	for pnode in get_tree().get_nodes_in_group("Player"):
		pnode.queue_free()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")


func _on_play_again_button_pressed():
	get_tree().reload_current_scene()
	finish_game_screen.hide()
