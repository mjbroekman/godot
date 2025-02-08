extends Node
class_name JumpState

@onready var player: Node = get_parent().get_parent()
var target_y_velocity : float = 0.0

func _physics_process(delta):
	if player.current_state in self.name:
		if player.is_on_floor():
			player.change_state("Idle")

		elif player.has_double_jump and player.can_double_jump and Input.is_action_just_pressed("jump"):
			player.change_state("Jump")
			player.velocity.y = -player.jump_height * delta
			player.can_double_jump = false
			player.jump_count += 1

		elif player.can_jump_dash and Input.is_action_just_pressed("dash"):
			player.change_state("Dash")

		elif not player.is_on_floor():
			player.change_state("Fall")


func reset_state() -> void:
	exit_state()
	start_state()

func start_state() -> void:
	player.anim.play("Jump",1.0)
	player.jump_count += 1
	if player.can_jump_dash:
		player.can_dash = true
	
	player.get_node("Jump").play()


func exit_state() -> void:
	player.jump_count = 0
	player.anim.stop()
