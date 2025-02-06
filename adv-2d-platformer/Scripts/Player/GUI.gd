extends CanvasLayer

@onready var gold_label : Label = get_node("Header/Gold")
@onready var heart_cont : HBoxContainer = get_node("Header/HeartContainer")

@onready var heart_scene : PackedScene = preload("res://Scenes/Player/Heart.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Game.health):
		var heart_temp : Node = heart_scene.instantiate()
		heart_cont.add_child(heart_temp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	gold_label.text = "Gold: " + str(Game.gold)
	if Game.health >= 1:
		if heart_cont.get_child_count() > Game.health:
			heart_cont.get_child(heart_cont.get_child_count() - 1).queue_free()
	else:
		#game over, man
		if heart_cont.get_child_count() > Game.health:
			heart_cont.get_child(heart_cont.get_child_count() - 1).queue_free()
