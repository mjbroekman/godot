class_name Item
extends Resource

@export var display_name : String
@export var icon : Texture2D
@export var max_stack_size : int = 12
@export var world_item_scene : PackedScene
@export var is_consumable = false

func on_use (player) -> bool:
	print("Used")
	return is_consumable
