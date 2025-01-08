extends InteractableObject

@export var time_to_grow : float = 5.0
@export var item_to_give : Item

@onready var grow_timer : Timer = get_node("Timer")
@onready var pumpkin : Node3D = get_node("Pumpkin")

func _interact():
	pumpkin.visible = false
	can_interact = false
	GlobalSignals.on_give_player_item.emit(item_to_give, 1)
	grow_timer.start(time_to_grow)


func _on_timer_timeout():
	pumpkin.visible = true
	can_interact = true
