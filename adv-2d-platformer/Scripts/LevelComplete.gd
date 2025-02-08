extends Area2D

@export var next_level : PackedScene = preload("res://Scenes/Levels/Level1.tscn")

func _on_body_entered(body):
	if "Player" in body.name:
		body.velocity.x = 0
		body.velocity.y = 0
		get_tree().change_scene_to_packed(next_level)
