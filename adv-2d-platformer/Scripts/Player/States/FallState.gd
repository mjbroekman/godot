extends Node
class_name FallState

@onready var player: Node = get_parent().get_parent()

func reset_state() -> void:
	exit_state()
	start_state()

func start_state() -> void:
	player.anim.play("Jump",1.0)

func exit_state() -> void:
	player.anim.stop()
