extends Node
class_name DashState

var dash_node : PackedScene = preload("res://Scenes/Player/DashNode.tscn")
@onready var player: Node = get_parent().get_parent()

var pos : bool

func _physics_process(_delta):
	if player.current_state in self.name:
		var dash_tmp : Node = dash_node.instantiate()
		dash_tmp.global_position = player.global_position
		player.get_parent().add_child(dash_tmp)

		if pos:
			dash_tmp.direction = -1
		else:
			dash_tmp.direction = 1


func reset_state() -> void:
	exit_state()
	start_state()

func start_state() -> void:
	player.anim.play("Dash",2.0)
	player.jump_count = 0
	player.can_dash = false
	pos = player.anim.flip_h
	if pos:
		player.velocity.x = 300
	else:
		player.velocity.x = -300
	await get_tree().create_timer(0.2).timeout
	player.change_state("Idle")

func exit_state() -> void:
	player.anim.stop()
	player.can_dash = true
