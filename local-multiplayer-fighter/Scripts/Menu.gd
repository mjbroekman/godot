extends Control

func _ready():
	_on_back_button_pressed()


func _on_initial_button_pressed():
	get_node("GameMode").hide()
	get_node("PlayerConfig").show()

func _on_championship_button_pressed():
	Global.game_mode = Global.game_modes.Championship
	
func _on_back_button_pressed():
	get_node("GameMode").show()
	get_node("PlayerConfig").hide()

func _on_singlematch_button_pressed():
	Global.game_mode = Global.game_modes.SingleMatch


func _on_quit_button_pressed():
	get_tree().quit()


func _on_play_button_pressed():
	var player1_config = get_node("PlayerConfig/VBoxContainer/HBoxContainer/Player1Config")
	var player2_config = get_node("PlayerConfig/VBoxContainer/HBoxContainer/Player2Config")

	for node in player1_config.get_children():
		if node is ColorPickerButton:
			Global.player1_colors.append(node.color)

	for node in player2_config.get_children():
		if node is ColorPickerButton:
			Global.player2_colors.append(node.color)

	for p1_color in Global.player1_colors:
		print(p1_color)

	get_tree().change_scene_to_file("res://Scenes/Levels/Level0.tscn")
