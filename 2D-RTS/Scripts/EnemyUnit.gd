extends Unit

var rng = RandomNumberGenerator.new()

func _ready():
	super._ready()

	is_player = false

	var enemy_id = rng.randi_range(108,112)
	sprite.texture = load(str("res://Sprites/tile_0",enemy_id,".png"))
