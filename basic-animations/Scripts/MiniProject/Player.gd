extends RigidBody2D

@export var can_jump : bool

@onready var anim_player : AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and can_jump:
		print("Jumping!")
		anim_player.play("Jump")


func _on_body_entered(body):
	if body.is_in_group("TileMapLayer"):
		print("Landing!")
		anim_player.play("Idle")
