extends Area2D

@onready var level1 = load("res://Level1.tscn")
@onready var level2 = load("res://Level2.tscn")
@onready var level3 = load("res://Level3.tscn")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if self == get_node("/root/Main/EndFlag"):
			if get_tree().get_current_scene() == level1:
				print("Switching to level 2")
				get_tree().change_scene_to_file("res://Level2.tscn")
			if get_tree().get_current_scene() == level2:
				print("Switching to level 3")
				get_tree().change_scene_to_file("res://Level3.tscn")

		if self == get_node("/root/Main/JumpFlag"):
			print("Switching to level 3")
			get_tree().change_scene_to_file("res://Level3.tscn")
