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
	pass

func _on_craft_button_pressed():
	pass # Replace with function body.
