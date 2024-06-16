extends Node

@onready var window : Panel = get_node("CraftingWindow")
@onready var ui_parent : VBoxContainer = get_node("CraftingWindow/RecipeContainer")

@export var crafting_recipeui_scene : PackedScene
@export var recipes : Array[CraftingRecipe]

var recipe_uis : Array[CraftingRecipeUI]
var inventory : Inventory

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory = get_parent().get_node('Inventory')
	
	for recipe in recipes:
		var recipe_node = crafting_recipeui_scene.instantiate()
		ui_parent.add_child(recipe_node)
		recipe_node.recipe = recipe
		recipe_node.crafting = self
		recipe_uis.append(recipe_node)

