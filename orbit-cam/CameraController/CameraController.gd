extends CharacterBody3D

@onready var camera : Camera3D = get_node("Camera3D")

@export_category("Camera Motion")
@export var look_sensitivity : float = 0.0015
var camera_look_input : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	rotate_y(-camera_look_input.x * look_sensitivity)
	rotate_x(-camera_look_input.y * look_sensitivity)
	#camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	camera_look_input = Vector2.ZERO


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_look_input = event.relative
