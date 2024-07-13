extends AudioStreamPlayer

@export_category("Audio_Settings")
@export var sounds : Array[AudioStream]
var play_rate : float
var last_play_time : float = 0

func _ready():
	play_rate = randf_range(0.1,1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Time.get_unix_time_from_system() - last_play_time < play_rate:
		return

	if ! self.playing:
		last_play_time = Time.get_unix_time_from_system()
		stream = sounds[randi() % len(sounds)]
		play()
	
