extends CharacterBody2D


const SPEED = 30.0

var change_dir : bool = false
@onready var ray_cliff : RayCast2D = get_node("CliffCheck")
@onready var ray_wall : RayCast2D = get_node("WallCheck")
var move_dir : int = -1

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if ( ! ray_cliff.is_colliding() ) || ray_wall.is_colliding():
		print("Switch direction!")
		change_dir = !change_dir
		if change_dir:
			move_dir = 1
		else:
			move_dir = -1

	ray_cliff.position.x = abs(ray_cliff.position.x) * move_dir
	ray_wall.target_position.x = abs(ray_wall.target_position.x) * move_dir

	print("Cliff RayCast2D X position = " + str(ray_cliff.position.x))
	print("Wall RayCast2D X target = " + str(ray_wall.target_position.x))
	print("Change direction? " + str(change_dir))
	print("Move direction? " + str(move_dir))

	velocity.x = SPEED * move_dir
	get_node('AnimatedSprite2D').flip_h = change_dir

	move_and_slide()
