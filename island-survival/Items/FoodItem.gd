class_name FoodItem
extends Item

@export var heal_amount : int = 10

func _on_use (player) -> bool:
	print("Using food...")
	player.get_node("Health").heal(heal_amount)
	return true
