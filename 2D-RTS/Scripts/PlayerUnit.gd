extends Unit

@onready var selection_visual : Sprite2D = get_node("SelectionVisual")

func _ready():
	super._ready()

	is_player = true
	gm.player_units.append(self)


func toggle_selection_visual(toggle):
	selection_visual.visible = toggle

