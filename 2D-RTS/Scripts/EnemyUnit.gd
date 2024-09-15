extends Unit

var rng = RandomNumberGenerator.new()
var detect_range : float = 100.0

func _ready():
	super._ready()

	is_player = false
	gm.enemy_units.append(self)

	move_speed = 40.0

	var enemy_id = rng.randi_range(108,112)
	sprite.texture = load(str("res://Sprites/tile_0",enemy_id,".png"))


func _process(delta):
	super._process(delta)
	
	if target == null:
		for player in gm.player_units:
			if player != null:
				var distance = global_position.distance_to(player.global_position)
				
				if distance <= detect_range:
					set_target(player)
