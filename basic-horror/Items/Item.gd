class_name Item
extends Resource

@export var display_name : String
@export var icon : Texture2D
@export var max_stack_size : int = 12
@export var world_item_scene : PackedScene
@export var can_drop : bool = true

func _on_use (player) -> bool:
	return false
