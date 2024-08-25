extends Sprite2D

@export var isMoving : bool
@export var speed : float

@onready var anim_player : AnimationPlayer = get_node("AnimationPlayer")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print(speed)
	anim_player.speed_scale = speed

func not_moving() -> void:
	print("Not moving")

func print_number(number : float) -> void:
	print("The number is: " + str(number))
