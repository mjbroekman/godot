extends State

@export var damage : int = 5
@export var attack_rate : float = 1.0
var last_attack_time : float

func enter ():
	super.enter()
	controller.is_stopped = true
	controller.look_at_player = true

func update (delta):
	if can_attack():
		attack()
	
	if controller.player_distance > 1.2:
		state_machine.set_state("Chase")

func attack ():
	last_attack_time = Time.get_unix_time_from_system()
	controller.player.get_node("Health").take_damage(damage)

func can_attack () -> bool:
	return Time.get_unix_time_from_system() - last_attack_time > attack_rate
