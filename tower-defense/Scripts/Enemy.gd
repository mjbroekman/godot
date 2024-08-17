extends CharacterBody3D

@export_category("Movement")
@export var speed : float = 3
@export var max_speed : float = 6.5

@export_category("Attributes")
@export var health : int = 15
@export var value : int = 15

@onready var path : PathFollow3D = get_parent()

func _ready():
	Global.enemies_alive += 1
	speed += Global.wave * 0.5
	if speed > max_speed:
		speed = max_speed

	health += Global.wave * 5
	value = health
	#_dump_info()
	$HealthBar3D.setup(health)


func _dump_info() -> void:
	print("Speed = " + str(speed))
	print("Health = " + str(health))
	print("Value = " + str(value))


func _physics_process(delta):
	path.set_progress(path.progress + speed * delta)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if path.get_progress_ratio() >= 0.99:
		Global.health -= 20
		death()

	move_and_slide()

func take_damage(amount : int) -> void:
	health -= amount
	$HealthBar3D.update(health)

	if health <= 0:
		Global.update_money(value)
		death()

func death() -> void:
	Global.enemies_alive -= 1
	path.queue_free()
