extends AudioStreamPlayer3D

@export_category("Audio_Settings")
@export var footstep_sounds : Array[AudioStream]
@export var play_rate : float = 0.5
@export var minimum_velocity : float = 0.25 # minimum delta speed to hear footsteps
var last_play_time : float = 0

@onready var bug : CharacterBody3D = get_parent()
@onready var statemachine : StateMachine = bug.get_node("StateMachine")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# don't play footsteps in the air
	if ! bug.is_on_floor():
		return

	play_rate = 0.5
	
	if bug.running:
		play_rate = 0.25
	
	# don't play if we aren't moving fast enough
	if bug.velocity.length() < minimum_velocity:
		return
	
	if Time.get_unix_time_from_system() - last_play_time < play_rate:
		return
	
	#if ! self.playing:
		#last_play_time = Time.get_unix_time_from_system()
		#stream = footstep_sounds[randi() % len(footstep_sounds)]
		#play()
	last_play_time = Time.get_unix_time_from_system()
	stream = footstep_sounds[randi() % len(footstep_sounds)]
	play()
