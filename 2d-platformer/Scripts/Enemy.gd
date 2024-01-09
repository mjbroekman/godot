extends Area2D

var move_speed : float = 30.0
var move_dir : Vector2

var start_pos : Vector2
var target_pos : Vector2
var rng = RandomNumberGenerator.new()

var visual : Texture2D

var my_sprites : Array
var cur_sprite : int
var time_delay : float = 1.0
var last_chg : float = 0.0

var enemy_anims : Array = [
	[ "15", "16", "17", "16" ],
	[ "18", "19", "20", "19" ],
	[ "21", "22", "23", "22" ],
	[ "24", "25", "26", "25" ]
]

func _ready():
	var my_anim = enemy_anims[rng.randi_range(0,3)]
	print(my_anim)
	my_sprites = _get_sprites(my_anim)
	cur_sprite = 0
	$EnemySprite.texture = my_sprites[cur_sprite]

	print(my_anim[0])
	if my_anim[0] == "24": # We are a flier, so we need to move up/down
		move_dir = Vector2(0, rng.randf_range(-20.0,-30.0))
	else: # We are a crawler
		move_dir = Vector2(rng.randf_range(20.0,25.0), 0)

	start_pos = global_position
	target_pos = start_pos + move_dir


func _get_sprites(anim_array):
	var sprite_array : Array = [
		load("res://Sprites/Characters/character_00" + anim_array[0] + ".png"),
		load("res://Sprites/Characters/character_00" + anim_array[1] + ".png"),
		load("res://Sprites/Characters/character_00" + anim_array[2] + ".png"),
		load("res://Sprites/Characters/character_00" + anim_array[3] + ".png"),
	]
	return sprite_array


func _process(delta):
	global_position = global_position.move_toward(target_pos, move_speed * delta)
	# Increment and mod by the size of the sprite array to get the new sprite
	last_chg += delta
	if last_chg > time_delay:
		last_chg -= time_delay
		cur_sprite = ( cur_sprite + 1 ) % 4
		$EnemySprite.texture = my_sprites[cur_sprite]

	# If we have reached our target position, we need to reverse direction.
	if global_position == target_pos:
		# If our target position is our original start position, we need to 
		# go to the "move_dir" destination. Otherwise, we need to return to
		# our original start position.
		if global_position == start_pos:
			target_pos = start_pos + move_dir
		else:
			target_pos = start_pos


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.game_over()
