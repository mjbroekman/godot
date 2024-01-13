extends CharacterBody2D
class_name Unit

# base characteristics
var health : int = 100
var damage : int = 20
var move_speed : float = 50.0
var atk_range : float = 20.0
var atk_speed : float = 5.0

# tracking vars
var last_atk_time : float
var target : CharacterBody2D = null

# self references
var agent : NavigationAgent2D
var sprite : Sprite2D

# player tracker
var is_player : bool


func _ready():
	agent = $UnitNavigator
	sprite = $Sprite


func _process(delta):
	_target_check()


func _physics_process(delta):
	if agent.is_navigation_finished():
		return
	
	var direction = global_position.direction_to(agent.get_next_path_position())
	velocity = direction * move_speed * delta
	move_and_slide()


func _target_check():
	if target != null:
		var dist = global_position.distance_to(target.global_position)
		if dist <= atk_range:
			agent.target_position = global_position
			_try_atk_target()
		else:
			agent.target_position = target.global_position


func take_damage(dmg_to_take):
	health -= dmg_to_take
	
	if health <= 0:
		queue_free()


func _try_atk_target():
	var current_time = Time.get_unix_time_from_system()

	if target == null:
		return

	if (current_time - last_atk_time) > atk_speed:
		target.take_damage(damage)
		last_atk_time = current_time


func set_target(new_target):
	target = new_target


func move_to_location(location):
	target = null
	agent.target_position = location

