extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player position: " + str(body.position))
		body.reset_player()
