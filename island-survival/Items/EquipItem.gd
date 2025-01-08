class_name EquipItem
extends Item

@export var equip_scene : PackedScene

func _on_use (player) -> bool:
	player.get_node("EquipController").equip(self)
	return false
