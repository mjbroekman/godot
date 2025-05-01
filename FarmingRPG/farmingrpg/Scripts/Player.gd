extends CharacterBody2D

@export var speed : int = 100


func _ready():
	pass


func _process(delta):
	player_movement()


func player_movement() -> void:
	var input = Input.get_vector("left","right","up","down")
	velocity = input.normalized() * speed
	move_and_slide()
