class_name CraftingRecipeUI
extends Node

var item_icon : TextureRect
var recipe_text : Label
var craft_button : Button
var recipe : CraftingRecipe
var crafting

func get_nodes():
	item_icon = get_node('ItemIcon')
	recipe_text = get_node('RecipeText')
	craft_button = get_node('CraftButton')

func update_recipe( inventory : Inventory ):
	var can_craft = true
	
	get_nodes()

	# Set up the recipe text
	recipe_text.text = recipe.item.display_name + "\n"

	# Set the icon TEXTURE to the item icon
	item_icon.texture = recipe.item.icon

	# Set up the recipe text.
	for req in recipe.requirements:
		recipe_text.text += req.item.display_name + " x" + str(req.quantity)
		if inventory.get_num_of_item(req.item) < req.quantity:
			recipe_text.text += " ( missing x" + str(req.quantity - inventory.get_num_of_item(req.item))+ " )"
			can_craft = false

		recipe_text.text += "\n"

	# Set the visibility of the crafting button
	craft_button.disabled = not can_craft

func _on_craft_button_pressed():
	crafting.craft(recipe)
