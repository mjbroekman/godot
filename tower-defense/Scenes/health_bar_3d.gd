extends Sprite3D

@onready var health_bar : ProgressBar = $SubViewport/HealthBar

func _ready():
	self.texture = $SubViewport.get_texture()


func setup(amount : int) -> void:
	health_bar.setup_bar(amount)


func update(amount : int) -> void:
	health_bar.update_bar(amount)
