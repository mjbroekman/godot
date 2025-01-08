extends ProgressBar

@onready var health_text : Label = get_node("HealthText")

func _ready():
	var health = get_parent().get_node("Health")
	health.on_change.connect(on_health_change)
	on_health_change(health.cur_health, health.max_health)

func on_health_change (cur_health : int, max_val : int):
	max_value = max_val
	value = cur_health
	health_text.text = str(cur_health) + " / " + str(max_val)
