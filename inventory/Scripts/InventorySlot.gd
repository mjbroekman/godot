class_name InventorySlot
extends Node

@export var item : Item
@export var quantity : int
@onready var icon : TextureRect = get_node('Icon')
@onready var quantity_text : Label = get_node('QuantityLabel')
var inventory : Inventory

func set_item(new_item : Item):
	item = new_item
	if new_item == null:
		icon.visible = false
		quantity = 0
	else:
		quantity = 1
		icon.visible = true
		icon.texture = new_item.icon

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

func _on_mouse_entered():
	if item == null:
		inventory.info_text.text = ""
	else:
		inventory.info_text.text = item.display_name

func _on_mouse_exited():
	inventory.info_text.text = ""

func _on_pressed():
	if item == null:
		return
	
	var remove_on_use = item.on_use(inventory.get_parent())
	
	if remove_on_use:
		remove_item()

func drop_item():
	pass
