extends Area3D

@export var last_report_time : float
@onready var main_scene : Node3D = get_parent()
@onready var camera = main_scene.find_child("CameraController")
var camera_obj : PackedScene = load("res://CameraController/OrbitCam.tscn")

func _ready():
	last_report_time = 0


func _process(_delta):
	if Time.get_unix_time_from_system() - last_report_time > 2:
		last_report_time = Time.get_unix_time_from_system()


func _on_input_event(camera, event, position, normal, shape_idx):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
			camera.get_parent().remove_child(camera)
			camera.queue_free()
			var new_cam = camera_obj.instantiate()
			add_child(new_cam)


func _on_mouse_entered():
	print(str(self) + " => " + str(position))
