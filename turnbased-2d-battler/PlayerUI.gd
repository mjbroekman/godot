extends VBoxContainer

var actions : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	visible =  self.get_parent().is_player
	if self == get_node("/root/BattleScene/Player"):
		get_node("/root/BattleScene").character1_begin_turn.connect(_on_character_begin_turn)
		get_node("/root/BattleScene").character1_end_turn.connect(_on_character_end_turn)
	else:
		get_node("/root/BattleScene").character2_begin_turn.connect(_on_character_begin_turn)
		get_node("/root/BattleScene").character2_end_turn.connect(_on_character_end_turn)

	self.actions.push_back("PlayerUI/CombatAction1")
	self.actions.push_back("PlayerUI/CombatAction2")
	self.actions.push_back("PlayerUI/CombatAction3")
	self.actions.push_back("PlayerUI/CombatAction4")


func _on_character_begin_turn (character):
	if self == character:
		visible =  self.get_parent().is_player

		if visible:
			character.display_combat_actions()
#		print(character.char_name)
#		for action in character.combat_actions:
#			print(action.display_name)
#		_display_combat_actions(character.char_name,character.actions)


func _on_character_end_turn(_character):
	visible = false


#func _display_combat_actions(char_name,combat_actions):
#	print(char_name + " has action buttons!")
#	for i in len(actions):
#		var button = get_node(actions[i])
#
#		if i < len(combat_actions):
#			button.visible = true
#			button.text = combat_actions[i].display_name
#			button.combat_action = combat_actions[i]
#		else:
#			button.visible = false
