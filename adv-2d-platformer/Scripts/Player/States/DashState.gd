extends Node
class_name DashState

@onready var player: Node = get_parent().get_parent()

func reset_state() -> void:
	exit_state()
	start_state()

func start_state() -> void:
	print("Starting to Dash")
	player.anim.play("Dash",2.0)
	player.jump_count = 0
	player.can_dash = false

func exit_state() -> void:
	player.anim.stop()
