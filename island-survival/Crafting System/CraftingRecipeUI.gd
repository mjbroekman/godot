class_name CraftingRecipeUI
extends Node

var item_icon : TextureRect
var recipe_text : Label
var craft_button : Button
var recipe : CraftingRecipe
var crafting

func get_nodes ():
	item_icon = get_node("ItemIcon")
	recipe_text = get_node("RecipeText")
	craft_button = get_node("CraftButton")

func update_recipe (inventory : Inventory):
	var can_craft = true
	
	for req in recipe.requirements:
		if inventory.get_number_of_item(req.item) < req.quantity:
			can_craft = false
			break
	
	get_nodes()
	craft_button.visible = can_craft
	recipe_text.text = recipe.item.display_name + "\n"
	
	for req in recipe.requirements:
		recipe_text.text += req.item.display_name + " x" + str(req.quantity) + "\n"
	
	item_icon.texture = recipe.item.icon

func _on_craft_button_pressed ():
	crafting.craft(recipe)
