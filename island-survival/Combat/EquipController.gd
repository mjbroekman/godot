extends Node

@onready var equip_origin : Node3D = get_parent().get_node("Camera3D/EquipOrigin")
var current_equip : EquipObject
var current_equip_item : EquipItem

func equip (item : EquipItem):
	if current_equip_item == item:
		unequip()
		return
	
	unequip()
	
	var obj = item.equip_scene.instantiate()
	equip_origin.add_child(obj)
	current_equip = obj
	current_equip.player = get_parent()
	current_equip_item = item

func unequip ():
	if current_equip == null:
		return
	
	current_equip.queue_free()
	current_equip = null
	current_equip_item = null

