extends InteractableObject

@onready var light_bulb = get_node("LightBulb")
# Called when the node enters the scene tree for the first time.
func _ready():
	interact_prompt = "Touch Pedestal"
	can_interact = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _interact():
	light_bulb.visible = true
	can_interact = false
