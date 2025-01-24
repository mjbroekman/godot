extends Node
class_name IdleState

@onready var player: Node = get_parent().get_parent()

func reset_state() -> void:
	exit_state()
	start_state()

func start_state() -> void:
	player.anim.play("Idle",1.0)
	player.jump_count = 0
	player.can_dash = true

func exit_state() -> void:
	player.anim.stop()
