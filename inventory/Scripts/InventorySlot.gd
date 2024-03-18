class_name InventorySlot
extends Node

@export var item : Item
@export var quantity : int
@onready var icon : TextureRect = get_node('Icon')
@onready var quantity_text : Label = get_node('QuantityLabel')
var inventory : Inventory

func set_item(new_item : Item):
	item = new_item
	quantity = 1

	if item == null:
		icon.visible = false
	else:
		icon.visible = true
		icon.texture = item.icon

	update_qty_text()

func add_item():
	quantity += 1
	update_qty_text()

func remove_item():
	quantity -= 1
	
	if quantity == 0:
		set_item(null)
	else:
		update_qty_text()

func update_qty_text():
	if quantity <= 1:
		quantity_text.text = ""
	else:
		quantity_text.text = str(quantity)
