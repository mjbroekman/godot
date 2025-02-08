extends CanvasLayer

@onready var game_over_audio : AudioStreamPlayer2D = get_node("Panel/AudioStreamPlayer2D")
@onready var retry_button : Button = get_node("Panel/VBoxContainer/Retry")
@onready var score_label : Label = get_node("Panel/VBoxContainer/ScoreLabel")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	self.get_tree().paused = false

func game_over():
	self.get_tree().paused = true
	retry_button.disabled = true
	score_label.text = "You collected " + str(Game.gold) + " Gold!"
	self.show()
	game_over_audio.play()
	await game_over_audio.finished
	retry_button.disabled = false

func _on_retry_pressed():
	Game.reset_game()
	self.hide()
	retry_button.disabled = true
	get_tree().reload_current_scene()
