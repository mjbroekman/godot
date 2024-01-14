extends CharacterBody2D
class_name Unit

# base characteristics
var health : int = 100
var damage : int = 10
var move_speed : float = 50.0
var atk_range : float = 20.0
var atk_speed : float = 1.0

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
	print(agent)
	print(sprite)


func _process(delta):
	_target_check()


func _physics_process(delta):
	if agent != null:
		if agent.is_navigation_finished():
			return
	
		var direction = global_position.direction_to(agent.get_next_path_position())
		velocity = direction * move_speed
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
	print(str(self," took ", dmg_to_take, ". Remaining health: ", health))
	sprite.modulate = Color.RED
	if health <= 0:
		queue_free()

	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE



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
	# target = null
	print(agent)
	agent.target_position = location

