extends RigidBody2D

var game_manager : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_node("/root/Main/Camera/Manager")
	self.linear_damp = game_manager.game_drag
	self.mass = game_manager.crate_mass
	self.position = Vector2(game_manager.rng.randf_range(game_manager.min_position[0],game_manager.max_position[0]),game_manager.rng.randf_range(game_manager.min_position[1],game_manager.max_position[1]))
	self.get_node("CrateSprite").scale *= (mass / game_manager.base_scale)
	self.get_node("CrateCollider").scale *= (mass / game_manager.base_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.position[0] < game_manager.min_position[0]:
		game_manager.increase_score(self.mass)
		queue_free()

	if self.position[1] < game_manager.min_position[1]:
		game_manager.increase_score(self.mass)
		queue_free()
	
	if self.position[0] > game_manager.max_position[0]:
		game_manager.increase_score(self.mass)
		queue_free()
	
	if self.position[1] > game_manager.max_position[1]:
		game_manager.increase_score(self.mass)
		queue_free()
