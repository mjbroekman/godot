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
	
	close()


func craft(recipe : CraftingRecipe):
	# Remove each of the recipe requirements
	for req in recipe.requirements:
		for qty in req.quantity:
			inventory.remove_item(req.item)
	
	# Add the crafted item
	inventory.add_item(recipe.item)
	
	# Update the crafting UI again.
	_update()


func _process(delta):
	if Input.is_action_just_pressed("Crafting"):
		if window.visible:
			close()
		else:
			open()

func open():
	window.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	_update()

# Separate update function so we don't perform unnecessary window / mouse_mode operations
func _update():
	for recipe in recipe_uis:
		recipe.update_recipe(inventory)


func close():
	window.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

