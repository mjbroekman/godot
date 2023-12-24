extends Node2D
class_name Character

@export var is_player : bool
@export var cur_hp : int = 25
@export var max_hp : int = 25

@export var actions : Array
@export var opponent : Node

@export var visual : Texture2D

@onready var health_bar : ProgressBar = get_node("HealthBar")
@onready var health_txt : Label = get_node("HealthBar/Label")
@onready var health_spk : CPUParticles2D = get_node("HealthBar/CPUParticles2D")

var max_emit_time : float = 0.5
var cur_emit_time : float = 0.0

## Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()

	health_bar.max_value = max_hp
	health_bar.value = cur_hp
	health_txt.text = str( cur_hp, "/", max_hp )
	
	get_node("/root/BattleScene").character_begin_turn.connect(_on_character_begin_turn)
	get_node("/root/BattleScene").character_end_turn.connect(_on_character_end_turn)
	
	$Sprite.texture = load(get_node("/root/BattleScene").characters[rng.randi_range(0,get_node("/root/BattleScene").characters.size())])

	if str(self.get_path()) == "/root/BattleScene/Player":
		is_player = true
		$Sprite.flip_h = false

	if str(self.get_path()) == "/root/BattleScene/Player2":
		is_player = false
		$Sprite.flip_h = true

	actions.push_front(load("res://CombatActions/5DMG.tres"))

	if ($Sprite.texture.get_path()) == "res://Sprites/Boar.png":
		actions.push_back(load("res://CombatActions/5HEAL.tres"))
		actions.push_back(load("res://CombatActions/8DMG.tres"))
		
		actions[0].display_name = "Gore (5 dmg)"
		actions[1].display_name = "Wallow (5 heal)"
		actions[2].display_name = "Charge (8 dmg)"

	if ($Sprite.texture.get_path()) == "res://Sprites/Dragon.png":
		actions.push_back(load("res://CombatActions/5HEAL.tres"))
		actions.push_back(load("res://CombatActions/8DMG.tres"))
		
		actions[0].display_name = "Claw (5 dmg)"
		actions[1].display_name = "Regen (5 heal)"
		actions[2].display_name = "Fire Breath (8 dmg)"

	if ($Sprite.texture.get_path()) == "res://Sprites/Reptile.png":
		actions.push_back(load("res://CombatActions/5HEAL.tres"))
		actions.push_back(load("res://CombatActions/8DMG.tres"))
		
		actions[0].display_name = "Slash (5 dmg)"
		actions[1].display_name = "Heal (5 heal)"
		actions[2].display_name = "Bash (8 dmg)"

	if ($Sprite.texture.get_path()) == "res://Sprites/Snake.png":
		actions.push_back(load("res://CombatActions/STEAL.tres"))
		actions.push_back(load("res://CombatActions/POWER_ATT.tres"))
		
		actions[0].display_name = "Bite (5 dmg)"
		actions[1].display_name = "Squeeze (3 dmg / 2 heal)"
		actions[2].display_name = "Poison (9 dmg)"


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
		get_node("/root/BattleScene").character_died(self)
		queue_free()


func heal(damage):
	cur_hp += damage

	if cur_hp > max_hp:
		cur_hp = max_hp

	_update_health_bar()


func _on_character_begin_turn(character):
	pass


func _on_character_end_turn(character):
	pass


func cast_combat_action(action):
	pass
