extends CharacterBody2D


const SPEED = 30.0

var change_dir : bool = false
@onready var ray_cliff : RayCast2D = get_node("CliffCheck")
@onready var ray_wall : RayCast2D = get_node("WallCheck")
var move_dir : int = -1
var am_dead : bool = false

func _physics_process(delta):
	if am_dead:
		var new_scale = 1.0 - get_node("DeathAudio").get_playback_position()
		self.scale.x = new_scale
		self.scale.y = new_scale
		return

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


func _on_head_damage_body_entered(body):
	if "Player" in body.name:
		death()

func _on_player_damage_body_entered(body):
	if "Player" in body.name:
		if "Dash" in body.current_state:
			death()
		else:
			Game.health -= 1
			if body.get_node("Hit") != null:
				body.get_node("Hit").play()

func death():
	am_dead = true
	get_node("BodyCollider").queue_free()
	get_node("PlayerDamage").queue_free()
	get_node("CliffCheck").queue_free()
	get_node("WallCheck").queue_free()
	get_node("DeathAudio").play()


func _on_death_audio_finished():
	queue_free()
