extends Node2D
class_name Character

var is_player : bool
var cur_hp : int = 25
var max_hp : int = 25
var char_name : String

var combat_actions : Array
var opponent : Node

var visual : Texture2D

@onready var health_bar : ProgressBar = get_node("HealthBar")
@onready var health_txt : Label = get_node("HealthBar/Label")
@onready var health_spk : CPUParticles2D = get_node("HealthBar/CPUParticles2D")
@onready var ui_mgr : VBoxContainer = get_node("PlayerUI")

var max_emit_time : float = 0.5
var cur_emit_time : float = 0.0
var rng = RandomNumberGenerator.new()

## Called when the node enters the scene tree for the first time.
func _ready():
	var char_list = get_node("/root/BattleScene").characters
	var char_size= char_list.size()

	self.health_bar.max_value = max_hp
	self.health_bar.value = cur_hp
	self.health_txt.text = str( cur_hp, "/", max_hp )
	
	$Sprite.texture = load(char_list[rng.randi_range(0,(char_size - 1))])
	self.char_name = (str($Sprite.texture.get_path()).split("/")[-1]).split(".")[0]
	if str(self.get_path()) == "/root/BattleScene/Player":
		get_node("/root/BattleScene").character1_begin_turn.connect(_on_character_begin_turn)

		self.is_player = true
		$Sprite.flip_h = false
		self.opponent = get_node("/root/BattleScene/Player2")
		_load_actions()
		_set_buttons()

	if str(self.get_path()) == "/root/BattleScene/Player2":
		get_node("/root/BattleScene").character2_begin_turn.connect(_on_character_begin_turn)

		self.is_player = false
		$Sprite.flip_h = true
		self.opponent = get_node("/root/BattleScene/Player")
		_load_actions()
		_set_buttons()

	for action in self.combat_actions:
		print(self.char_name + ": " + action.display_name)

func _load_actions():
	if str($Sprite.texture.get_path()) == "res://Sprites/Boar.png":
		self.combat_actions.append(load("res://CombatActions/5DMG.tres"))
		self.combat_actions[0].display_name = "Gore (5 dmg)"
		self.combat_actions[0].heal_amt = 0
		self.combat_actions[0].damage_amt = 5

		self.combat_actions.append(load("res://CombatActions/5HEAL.tres"))
		self.combat_actions[1].display_name = "Wallow (5 heal)"
		self.combat_actions[1].heal_amt = 5
		self.combat_actions[1].damage_amt = 0

		self.combat_actions.append(load("res://CombatActions/8DMG.tres"))
		self.combat_actions[2].display_name = "Charge (8 dmg)"
		self.combat_actions[2].heal_amt = 0
		self.combat_actions[2].damage_amt = 8

	if str($Sprite.texture.get_path()) == "res://Sprites/Dragon.png":
		self.combat_actions.append(load("res://CombatActions/5DMG.tres"))
		self.combat_actions[0].display_name = "Claw (5 dmg)"
		self.combat_actions[0].heal_amt = 0
		self.combat_actions[0].damage_amt = 5

		self.combat_actions.append(load("res://CombatActions/5HEAL.tres"))
		self.combat_actions[1].display_name = "Regen (5 heal)"
		self.combat_actions[1].heal_amt = 5
		self.combat_actions[1].damage_amt = 0

		self.combat_actions.append(load("res://CombatActions/8DMG.tres"))
		self.combat_actions[2].display_name = "Fire Breath (8 dmg)"
		self.combat_actions[2].heal_amt = 0
		self.combat_actions[2].damage_amt = 8

	if str($Sprite.texture.get_path()) == "res://Sprites/Reptile.png":
		self.combat_actions.append(load("res://CombatActions/5DMG.tres"))
		self.combat_actions[0].display_name = "Slash (5 dmg)"
		self.combat_actions[0].heal_amt = 0
		self.combat_actions[0].damage_amt = 5

		self.combat_actions.append(load("res://CombatActions/5HEAL.tres"))
		self.combat_actions[1].display_name = "Heal (5 heal)"
		self.combat_actions[1].heal_amt = 5
		self.combat_actions[1].damage_amt = 0

		self.combat_actions.append(load("res://CombatActions/8DMG.tres"))
		self.combat_actions[2].display_name = "Bash (8 dmg)"
		self.combat_actions[2].heal_amt = 0
		self.combat_actions[2].damage_amt = 8

	if str($Sprite.texture.get_path()) == "res://Sprites/Snake.png":
		self.combat_actions.append(load("res://CombatActions/5DMG.tres"))
		self.combat_actions[0].display_name = "Bite (5 dmg)"
		self.combat_actions[0].heal_amt = 0
		self.combat_actions[0].damage_amt = 5

		self.combat_actions.append(load("res://CombatActions/STEAL.tres"))
		self.combat_actions[1].display_name = "Squeeze (3 dmg / 2 heal)"
		self.combat_actions[1].heal_amt = 2
		self.combat_actions[1].damage_amt = 3

		self.combat_actions.append(load("res://CombatActions/POWER_ATT.tres"))
		self.combat_actions[2].display_name = "Poison (9 dmg)"
		self.combat_actions[2].heal_amt = 0
		self.combat_actions[2].damage_amt = 9


func _set_buttons():
	for i  in len(ui_mgr.actions):
		var button = get_node(ui_mgr.actions[i])
		
		if i < len(self.combat_actions):
			button.text = self.combat_actions[i].display_name
			button.combat_action = self.combat_actions[i]


func _decide_combat_action():
	if cur_hp < 10:
		cast_combat_action(combat_actions[1])
	else:
		cast_combat_action(combat_actions[rng.randi_range(0,(len(combat_actions)-1))])


func display_combat_actions():
	for i in len(ui_mgr.actions):
		var button = get_node(ui_mgr.actions[i])

		if i < len(self.combat_actions):
			button.visible = true
		else:
			button.visible = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.health_spk.emitting:
		self.cur_emit_time += delta
		if self.cur_emit_time > max_emit_time:
			self.cur_emit_time = 0.0
			self.health_spk.emitting = false


func _update_health_bar():
	if self.cur_hp < self.health_bar.value:
		self.health_spk.emitting = true
		self.health_spk.color = "#c215a7"
	if self.cur_hp > self.health_bar.value:
		self.health_spk.emitting = true
		self.health_spk.color = "#34d427"

	self.health_bar.value = cur_hp
	self.health_txt.text = str( cur_hp, "/", max_hp )


func take_damage(damage):
	self.cur_hp -= damage
	
	_update_health_bar()

	if self.cur_hp <= 0:
		get_node("/root/BattleScene").character_died(self)
		queue_free()


func heal(damage):
	self.cur_hp += damage

	if self.cur_hp > self.max_hp:
		self.cur_hp = self.max_hp

	_update_health_bar()


func _on_character_begin_turn(character):
	if self == character and is_player == false:
		ui_mgr.visible = false
		_decide_combat_action()
	elif self == character and is_player:
		ui_mgr.visible = true


func cast_combat_action(action):
	if action.damage_amt > 0:
		print(str(action.display_name) + " is dealing " + str(action.damage_amt) + " damage")
		opponent.take_damage(action.damage_amt)
	
	if action.heal_amt > 0:
		print(str(action.display_name) + " is healing " + str(action.heal_amt) + " health")
		self.heal(action.heal_amt)
	
	get_node("/root/BattleScene").end_cur_turn()
