extends Node

@onready var equip_origin : Node3D = get_parent().get_node("Camera3D/EquipOrigin")
var current_equip : EquipObject # Current item that is the child of equip_origin
var current_equip_item : EquipItem # item resource representing current_equip

func equip(item : EquipItem):
	if current_equip_item == item:
		unequip()
		return
	
	unequip()
	
	var object = item.equip_scene.instantiate()
	equip_origin.add_child(object)
	current_equip = object
	current_equip.player = get_parent()
	current_equip_item = item

func unequip():
	if current_equip_item == null:
		return
	
	current_equip.queue_free()
	current_equip = null
	current_equip_item = null

