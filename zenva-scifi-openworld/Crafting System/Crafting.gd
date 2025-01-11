extends Node

@onready var window : Panel = get_node("CraftingWindow")
@onready var ui_parent : VBoxContainer = get_node("CraftingWindow/RecipeContainer")

@export var crafting_recipe_ui_scene : PackedScene
@export var recipes : Array[CraftingRecipe]

var recipe_uis : Array[CraftingRecipeUI]
var inventory : Inventory

func _ready():
	inventory = get_parent().get_node("Inventory")
	
	for recipe in recipes:
		var recipe_node = crafting_recipe_ui_scene.instantiate()
		ui_parent.add_child(recipe_node)
		recipe_node.recipe = recipe
		recipe_node.crafting = self
		recipe_uis.append(recipe_node)
	
	close()

func craft (recipe : CraftingRecipe):
	for req in recipe.requirements:
		for i in range(req.quantity):
			inventory.remove_item(req.item)
	
	inventory.add_item(recipe.item)
	open()

func _process(delta):
	if Input.is_action_just_pressed("crafting"):
		if window.visible:
			close()
		else:
			open()

func open ():
	window.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for recipe in recipe_uis:
		recipe.update_recipe(inventory)

func close ():
	window.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
