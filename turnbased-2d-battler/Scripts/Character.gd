extends Node2D
class_name Character

@export var is_player : bool
@export var cur_hp : int = 25
@export var max_hp : int = 25

@export var actions : Array
@export var opponent : Node

@onready var health_bar : ProgressBar = get_node("HealthBar")
@onready var health_txt : Label = get_node("HealthBar/Label")
@onready var health_spk : CPUParticles2D = get_node("HealthBar/CPUParticles2D")

var max_emit_time : float = 0.5
var cur_emit_time : float = 0.0
## Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.max_value = max_hp
	health_bar.value = cur_hp
	health_txt.text = str( cur_hp, "/", max_hp )

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health_spk.emitting:
		cur_emit_time += delta
		if cur_emit_time > max_emit_time:
			cur_emit_time = 0.0
			health_spk.emitting = false


func _update_health_bar():
	if cur_hp < health_bar.value:
		health_spk.emitting = true
		health_spk.color = "#c215a7"
	if cur_hp > health_bar.value:
		health_spk.emitting = true
		health_spk.color = "#34d427"

	health_bar.value = cur_hp
	health_txt.text = str( cur_hp, "/", max_hp )

func take_damage(damage):
	cur_hp -= damage
	
	_update_health_bar()

	if cur_hp <= 0:
		queue_free()


func heal(damage):
	cur_hp += damage

	if cur_hp > max_hp:
		cur_hp = max_hp

	_update_health_bar()
