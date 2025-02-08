extends Node2D


func _on_no_exit_body_entered(body):
	if "Player" in body.name:
		if "Dash" in body.current_state:
			body.change_state("Idle")

		if body.velocity.x > 0:
			body.position.x -= 15
		elif body.velocity.x < 0:
			body.position.x += 15
		body.velocity.x = 0

func _on_death_guard_body_entered(body):
	if "Player" in body.name:
		get_node("GameOver").game_over()


func _on_next_level_body_entered(body):
	pass # Replace with function body.
