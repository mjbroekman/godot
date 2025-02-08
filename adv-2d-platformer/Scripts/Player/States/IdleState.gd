extends Node
class_name IdleState

@onready var player: Node = get_parent().get_parent()

func _physics_process(delta):
	# If we are currently idle, we can only go into ONE of four states
	# - WalkState (if a/d or left/right arrow are pressed)
	# - JumpState (if the space bar is pressed)
	# - DashState (if the shift key is pressed)
	# - FallState (if we are idle and pushed off a floor by something else)
	if player.current_state in self.name:
		# if we press a movement key
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			player.change_state("Walk")

		# if we hit the space bar and still have jumps left
		elif Input.is_action_just_pressed("jump") and player.jump_count < player.max_jumps:
			if player.is_on_floor() or (not player.is_on_floor() and player.can_double_jump):
				player.change_state("Jump")
				player.velocity.y = -player.jump_height * delta

		# if we hit (or hold) the shift key
		elif Input.is_action_just_pressed("dash"):
			if player.is_on_floor() and player.can_dash:
				player.change_state("Dash")
			elif not player.is_on_floor() and player.can_jump_dash:
				player.change_state("Dash")
		
		# If the floor disappears or we get pushed/slide off
		elif not player.is_on_floor():
			player.change_state("Fall")
		
		player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)

func reset_state() -> void:
	exit_state()
	start_state()

func start_state() -> void:
	player.anim.play("Idle",1.0)
	player.jump_count = 0
	player.can_dash = true
	if player.has_double_jump:
		player.can_double_jump = true

func exit_state() -> void:
	player.anim.stop()
