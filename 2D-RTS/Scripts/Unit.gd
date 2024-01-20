extends CharacterBody2D
class_name Unit

# base characteristics
var health : int = 100
var max_health : int = 100

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
var gm : Node2D

# player tracker
var is_player : bool


func _ready():
	agent = $UnitNavigator
	sprite = $Sprite
	gm = get_node("/root/Main")


func _process(_delta):
	_target_check()


func _physics_process(_delta):
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


func take_damage(attacker,dmg_to_take):
	health -= dmg_to_take
	print(str(self," took ", dmg_to_take, ". Remaining health: ", health))
	sprite.modulate = Color.RED
	if target == null:
		set_target(attacker)

	if health <= 0:
		attacker.reward_attacker()
		queue_free()

	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE


func heal(amount):
	print(str('Healing ',amount,' dmg'))
	health += amount
	if health > max_health:
		health = max_health


func reward_attacker():
	if self.is_player:
		print('Level up!')
		sprite.modulate = Color.GREEN		
		max_health += max_health / 10
		print(str('New max_health = ',max_health))
		heal(max_health / 5)
		damage += 2
		print(str('Increasing damage output to ',damage))
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE


func _try_atk_target():
	var current_time = Time.get_unix_time_from_system()

	if target == null:
		return

	if (current_time - last_atk_time) > atk_speed:
		target.take_damage(self,damage)
		last_atk_time = current_time


func set_target(new_target):
	target = new_target


func move_to_location(location):
	# target = null
	print(agent)
	agent.target_position = location

