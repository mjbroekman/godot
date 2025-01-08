extends State

@export var flee_distance : float = 6.0
@export var safe_distance : float = 5.0

# Called when we enter into the state.
func enter ():
	super.enter()
	controller.running = true
	
	flee()

# Move in the opposite direction of the player.
func flee ():
	var player_dir = (controller.position - controller.player.position).normalized()
	controller.move_to_position(controller.position + (_random_offset() * flee_distance))

# Called when we exit the state.
func exit ():
	super.exit()
	controller.running = false

# Called every frame while in thwe state.
func update (delta):
	# State transitions.
	if controller.position.distance_to(controller.player.position) > safe_distance:
		state_machine.set_state("Wander")

# When we reach our destination and are still in this state, flee again.
func navigation_complete ():
	flee()
