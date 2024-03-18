class_name Inventory
extends Node

var inventory_slots : Array[InventorySlot]
@onready var window : Panel = get_node('InventoryPanel')
@onready var info_text : Label = get_node('InventoryPanel/InfoText')
@export var starter_items : Array[Item]

func _ready():
	toggle_window(false)
	
	for slot in get_node('InventoryPanel/InventoryGrid').get_children():
		inventory_slots.append(slot)
		slot.set_item(null)
		slot.inventory = self

	for item in starter_items:
		print(str("Adding ",item.display_name))
		add_item(item)

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		toggle_window(!window.visible)

func toggle_window(open : bool):
	window.visible = open

	if open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func on_give_player_item(new_item : Item, amount : int):
	for i in range(amount):
		add_item(new_item)

func add_item(new_item : Item):
	var slot = get_slot_to_add(new_item)

	if slot == null:
		return

	if slot.item == null:
		slot.set_item(new_item)
	elif slot.item == new_item:
		slot.add_item() # Call the add_item() function in the InventorySlot script

func remove_item(old_item : Item):
	var slot = get_slot_to_remove(old_item)

	if slot == null or slot.item == null:
		return

	slot.remove_item()

func get_slot_to_add(new_item : Item) -> InventorySlot:
	for slot in inventory_slots:
		if slot.item == new_item and slot.quantity < new_item.max_stack_size:
			return slot

	for slot in inventory_slots:
		if slot.item == null:
			return slot

	return null

func get_slot_to_remove(old_item : Item) -> InventorySlot:
	for slot in inventory_slots:
		if slot.item == old_item:
			return slot

	return null

func get_num_of_item(item : Item) -> int:
	var total = 0
	for slot in inventory_slots:
		if slot.item == item:
			total += slot.quantity

	return total


