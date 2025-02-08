extends Node
class_name WalkState

@onready var player: Node = get_parent().get_parent()

func _physics_process(delta):
	if player.current_state in self.name:
		if player.is_on_floor():
			if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
				player.change_state("Idle")

			# if we hit the space bar and still have jumps left
			elif Input.is_action_just_pressed("jump") and player.jump_count < player.max_jumps:
				player.change_state("Jump")
				player.velocity.y = -player.jump_height * delta

			# if we hit (or hold) the shift key
			if Input.is_action_just_pressed("dash"):
				if player.is_on_floor() and player.can_dash:
					player.change_state("Dash")
				elif not player.is_on_floor() and player.can_jump_dash:
					player.change_state("Dash")
			
		# If the floor disappears or we get pushed/slide off
		elif not player.is_on_floor():
			player.change_state("Fall")

		player.move_player(delta)


func reset_state() -> void:
	exit_state()
	start_state()

func start_state() -> void:
	player.anim.play("Walk",1.0)
	player.jump_count = 0
	player.can_dash = true

func exit_state() -> void:
	player.anim.stop()
