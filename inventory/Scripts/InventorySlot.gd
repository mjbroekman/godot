class_name InventorySlot
extends Node

@export var item : Item
@export var quantity : int
@onready var icon : TextureRect = get_node('Icon')
@onready var quantity_text : Label = get_node('QuantityLabel')
var inventory : Inventory

func set_item(new_item : Item):
	pass

func add_item():
	pass

func remove_item():
	pass

func update_qty_text():
	pass

