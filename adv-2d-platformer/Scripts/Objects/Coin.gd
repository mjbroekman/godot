extends Area2D

func _on_body_entered(body):
	if "Player" in body.name:
		self.get_node("Audio").play()
		self.get_node("AnimatedSprite2D").hide()
		Game.gold += 1 


func _on_audio_stream_player_2d_finished():
	queue_free() 
