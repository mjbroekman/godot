class_name CameraController
extends CharacterBody3D

@onready var camera : Camera3D = get_node("Camera3D")

@export_category("Camera Motion")
@export var look_sensitivity : float = 0.0015
@export var zoom_sensitivity : float = 0.5
var camera_look_input : Vector2
var camera_zoom_input : Vector2


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(_delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-camera_look_input.x * look_sensitivity)
		rotate_x(-camera_look_input.y * look_sensitivity)

	camera_look_input = Vector2.ZERO


func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel") or Input.is_key_label_pressed(KEY_ESCAPE) or Input.is_physical_key_pressed(KEY_ESCAPE) or Input.is_key_pressed(KEY_ESCAPE):
		_toggle_mouse()

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			camera_look_input = event.relative
		elif event.pressed and (event.keycode == 4194305 or event.keycode == "4194305"):
			_toggle_mouse()
		else:
			if event.pressed:
				print(event.keycode)


func _toggle_mouse():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
