extends State

var home_position : Vector3

@export var flee_range : float = 2.0
@export var max_flee_range : float = 15.0


func enter():
	super.enter()
	controller.is_running = true
	controller.look_at_player = false
	flee()


func exit():
	super.exit()
	controller.is_running = false


func flee():
	var current_time = Time.get_unix_time_from_system()
	var player_direction = (controller.position - controller.player.position).normalized()
	var move_pos = controller.position + (player_direction * max_flee_range)
	controller.move_to_position(move_pos, false)

	if controller.player_distance > max_flee_range:
		state_machine.change_state("Wander")

func navigation_complete():
	state_machine.change_state("Wander")

