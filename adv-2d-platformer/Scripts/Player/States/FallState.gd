extends Node
class_name FallState

@onready var player: Node = get_parent().get_parent()

func _physics_process(delta):
	if player.current_state in self.name:
		if player.is_on_floor():
			player.change_state("Idle")

		elif player.can_jump_dash and Input.is_action_just_pressed("dash"):
			player.change_state("Dash")

		player.velocity.x = lerp(player.velocity.x, 0.0, player.friction / 2.0)


func reset_state() -> void:
	exit_state()
	start_state()

func start_state() -> void:
	player.anim.play("Jump",1.0)

func exit_state() -> void:
	player.anim.stop()
