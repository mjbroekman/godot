extends Node

@export var chalice_item : Item
@export var chalice_to_win : int = 5
@onready var info_text : Label = get_node("InfoText")
@onready var win_screen : Panel = get_node("WinScreen")
@onready var lose_screen : Panel = get_node("LoseScreen")
@onready var inventory : Inventory = get_node("Player/Inventory")

var game_over : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.time_scale = 1
	win_screen.visible = false
	lose_screen.visible = false

func _process(delta):
	if game_over and Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()

func update_info_text():
	var current = inventory.get_number_of_item(chalice_item)
	info_text.text = "Find " + str(chalice_to_win - current) + " / " + str(chalice_to_win) + " chalices!"

func win_game():
	game_over = true
	win_screen.visible = true
	Engine.time_scale = 0

func lose_game():
	game_over = true
	lose_screen.visible = true
	Engine.time_scale = 0




