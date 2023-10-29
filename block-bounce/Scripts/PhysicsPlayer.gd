extends RigidBody2D

var game_manager : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_node("/root/Main/Camera/Manager")
	self.linear_damp = game_manager.game_drag
	self.mass = game_manager.player_mass
	self.get_node("PlayerSprite").scale *= (mass / game_manager.base_scale)
	self.get_node("PlayerCollider").scale *= (mass / game_manager.base_scale)
	print("Player Mass = %f" % self.mass)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var dir = global_position.direction_to(get_global_mouse_position())
		apply_impulse(dir * game_manager.game_force)
	
	if self.position[0] < game_manager.min_position[0]:
		self.position[0] = game_manager.min_position[0]

	if self.position[1] < game_manager.min_position[1]:
		self.position[1] = game_manager.min_position[1]
	
	if self.position[0] > game_manager.max_position[0]:
		self.position[0] = game_manager.max_position[0]
	
	if self.position[1] > game_manager.max_position[1]:
		self.position[1] = game_manager.max_position[1]

