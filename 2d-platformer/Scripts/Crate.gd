extends Area2D

@onready var tilemap : TileMap = get_node("/root/Main/TileMap")
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.has_double_jump = true
		print("Player has discovered 'Double Jump'")
		print(get_node("/root/Main/TileMap").get_layers_count())
		print("Crate at " + str(body.position) + " cracked open!")
		tilemap.clear_layer(1)
		queue_free()
