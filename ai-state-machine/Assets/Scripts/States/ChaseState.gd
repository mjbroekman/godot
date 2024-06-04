extends State

var home_position : Vector3

@export var stop_range : float = 2.0
@export var lose_interest_range : float = 10.0

var path_update_rate : float = 0.1
var last_path_update_time : float

func enter():
	super.enter()
	controller.is_running = true
	last_path_update_time = Time.get_unix_time_from_system()
	controller.look_at_player = true


func exit():
	super.exit()
	controller.is_running = false
	controller.look_at_player = false


func update(delta):
	var current_time = Time.get_unix_time_from_system()
	
	if current_time - last_path_update_time > path_update_rate:
		last_path_update_time = current_time
		controller.move_to_position(controller.player.position, false)

	if controller.player_distance < stop_range:
		controller.is_stopped = true
	
	if controller.player_distance > lose_interest_range:
		state_machine.change_state("Wander")
