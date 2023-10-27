extends RigidBody2D

var game_manager : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_node("/root/Main/Camera/Manager")
	self.linear_damp = game_manager.game_drag


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(self.position)
	if self.position[0] < game_manager.min_position[0]:
		queue_free()

	if self.position[1] < game_manager.min_position[1]:
		queue_free()
	
	if self.position[0] > game_manager.max_position[0]:
		queue_free()
	
	if self.position[1] > game_manager.max_position[1]:
		queue_free()
