class_name Inventory
extends Node

var inventory_slots : Array[InventorySlot]
@onready var window : Panel = get_node('InventoryPanel')
@onready var info_text : Label = get_node('InventoryPanel/InfoText')
@export var starter_items : Array[Item]

func _ready():
	pass

func _process(delta):
	pass

func toggle_window(open : bool):
	pass

func on_give_player_item(new_item : Item, amount : int):
	pass

func add_item(new_item : Item):
	pass

func remove_item(old_item : Item):
	pass

func get_slot_to_add(new_item : Item) -> InventorySlot:
	return null

func get_slot_to_remove(old_item : Item) -> InventorySlot:
	return null

func get_num_of_item(item : Item) -> int:
	return 0


