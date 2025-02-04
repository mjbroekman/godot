extends CharacterBody2D


const SPEED = 30.0

var change_dir : bool = false
@onready var ray_ground : RayCast2D = get_node("GroundCheck")
@onready var ray_wall : RayCast2D = get_node("WallCheck")
var move_dir : int = -1
var am_dead : bool = false

func _physics_process(delta):
	if am_dead:
		var new_scale = 1.0 - get_node("DeathAudio").get_playback_position()
		self.scale.x = new_scale
		self.scale.y = new_scale
		return

#	if ( ! ray_ground.is_colliding() ) || ray_wall.is_colliding():
	if ( ray_ground.is_colliding() ):
		print("Switch direction!")
		change_dir = !change_dir
		if change_dir:
			move_dir = 1
		else:
			move_dir = -1

	ray_ground.target_position.y = abs(ray_ground.target_position.y) * move_dir
	ray_wall.target_position.x = abs(ray_wall.target_position.x) * move_dir

	print("Ground RayCast2D Y target = " + str(ray_ground.target_position.y))
	print("Wall RayCast2D X target = " + str(ray_wall.target_position.x))
	print("Change direction? " + str(change_dir))
	print("Move direction? " + str(move_dir))

	velocity.y = SPEED * move_dir
	velocity.x = 0.0
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
	if get_node("BodyCollider") != null:
		get_node("BodyCollider").queue_free()
	if get_node("PlayerDamage") != null:
		get_node("PlayerDamage").queue_free()
	if get_node("GroundCheck") != null:
		get_node("GroundCheck").queue_free()
	if get_node("WallCheck") != null:
		get_node("WallCheck").queue_free()
	if get_node("DeathAudio") != null:
		get_node("DeathAudio").play()


func _on_death_audio_finished():
	queue_free()
