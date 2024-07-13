class_name Inventory
extends Node

var slots : Array[InventorySlot]
@onready var window : Panel = get_node("InventoryWindow")
@onready var info_text : Label = get_node("InventoryWindow/InfoText")

@export var starter_items : Array[Item]

func _ready ():
	toggle_window(false)
	
	for child in get_node("InventoryWindow/SlotContainer").get_children():
		slots.append(child)
		child.set_item(null)
		child.inventory = self
	
	GlobalSignals.on_give_player_item.connect(on_give_player_item)
	
	#for item in starter_items:
	#	add_item(item)

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		toggle_window(!window.visible)

func toggle_window (open):
	window.visible = open
	
	if open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func on_give_player_item (item : Item, amount : int):
	for i in range(amount):
		add_item(item)

func add_item (item : Item):
	var slot = get_slot_to_add(item)
	
	if slot == null:
		return
	
	if slot.item == null:
		slot.set_item(item)
	elif slot.item == item:
		slot.add_item()

func remove_item (item : Item):
	var slot = get_slot_to_remove(item)
	
	if slot.item == null:
		return
	
	slot.remove_item()

# Returns a slot to add a new item to.
func get_slot_to_add (item : Item) -> InventorySlot:
	# Look for an existing item slot.
	for slot in slots:
		if slot.item == item and slot.quantity < item.max_stack_size:
			return slot
	
	# Look for an empty slot.
	for slot in slots:
		if slot.item == null:
			return slot
	
	return null

# Returns a slot of the requested item to remove.
func get_slot_to_remove (item : Item) -> InventorySlot:
	for slot in slots:
		if slot.item == item:
			return slot
	
	return null

# Returns the total number of the requested item we have in the inventory.
func get_number_of_item (item : Item) -> int:
	var total = 0
	
	for slot in slots:
		if slot.item == item:
			total += slot.quantity
	
	return total
