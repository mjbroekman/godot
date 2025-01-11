extends ProgressBar

@onready var health_text : Label = get_node("HealthText")

func _ready():
	var health = get_parent().get_node("Health")
	health.on_change.connect(on_health_change)
	on_health_change(health.current, health.max_health)

func on_health_change (current : int, max_health : int):
	max_value = max_health
	value = current
	health_text.text = str(current) + " / " + str(max_health)
