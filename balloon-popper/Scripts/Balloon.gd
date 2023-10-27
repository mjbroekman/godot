extends Area3D

# instantiate a random number generator
var rng = RandomNumberGenerator.new()

# modify to 'chance to pop'
@export var chance_to_pop : float = 0.33
@export var clicks_to_pop : int = 3
@export var size_increase : float = 0.2
@export var score_to_give : int = 1
var balloon_score : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	chance_to_pop += rng.randf_range(-0.08,0.17)
	clicks_to_pop += rng.randi_range(-2,2)
	size_increase += rng.randf_range(-0.1,0.3)
	self.position = Vector3(rng.randf_range(-8.0,8.0),rng.randf_range(-2.0,2.0),rng.randf_range(-4.0,4.0))

# Called on input event (keystroke, mouse click, etc)
func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		scale += Vector3.ONE * size_increase
		if rng.randf() < chance_to_pop:
			print('balloon is getting thinner!')
			clicks_to_pop -= 1

		if clicks_to_pop == 0:
			get_node("/root/Main").increase_score(balloon_score)
			queue_free()
		
		balloon_score += score_to_give
