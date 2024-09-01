extends Area2D

@export var textures : Array[Texture2D]
@export var colors : Array[Color]

var sprite_index : int

@onready var anim_player : AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_index = randi() % textures.size()
	$Sprite2D.texture = textures[sprite_index]
	print("I am a newly spawned coin!")
	anim_player.play("Spawn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("Player"):
		anim_player.play("CollidedWithPlayer")
		$CoinCollectionFX.emit(colors[sprite_index])
