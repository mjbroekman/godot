extends Area3D

@export var last_report_time : float

func _ready():
	last_report_time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Time.get_unix_time_from_system() - last_report_time > 2:
		print(position)
		last_report_time = Time.get_unix_time_from_system()
