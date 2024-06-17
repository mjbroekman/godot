class_name EquipObject
extends Node3D

@onready var animation : AnimationPlayer = get_node("AnimationPlayer")
var player : PlayerController

func on_primary_use():
	pass

func on_secondary_use():
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == 1:
			on_primary_use()
		elif event.button_index == 2:
			on_secondary_use()

