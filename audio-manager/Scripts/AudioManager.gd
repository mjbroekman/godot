extends Node

@onready var window : Panel = get_node("AudioWindow")
@onready var master_slider : HSlider = get_node("AudioWindow/AudioControlBox/MasterVolumeContainer/MasterVolumeSlider")
@onready var ambient_slider : HSlider = get_node("AudioWindow/AudioControlBox/AmbientVolumeContainer/AmbientVolumeSlider")
@onready var music_slider : HSlider = get_node("AudioWindow/AudioControlBox/MusicVolumeContainer/MusicVolumeSlider")
@onready var sfx_slider : HSlider = get_node("AudioWindow/AudioControlBox/SFXVolumeContainer/SFXVolumeSlider")

var master_index : int
var ambient_index : int
var music_index : int
var sfx_index : int

func _ready():
	master_index = AudioServer.get_bus_index("Master")
	ambient_index = AudioServer.get_bus_index("Ambient")
	music_index = AudioServer.get_bus_index("Music")
	sfx_index = AudioServer.get_bus_index("SFX")
	
	master_slider.value = _get_volume(master_index)
	ambient_slider.value = _get_volume(ambient_index)
	music_slider.value = _get_volume(music_index)
	sfx_slider.value = _get_volume(sfx_index)
	
	window.visible = false


func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		window.visible = ! window.visible
	
	if window.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if ! window.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _get_volume(bus_index : int) -> float:
	var db_volume = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db_volume)


func _set_volume(bus_index : int, volume : float):
	var db_volume = linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, db_volume)


func _on_master_volume_slider_value_changed(value):
	_set_volume(master_index, value)


func _on_ambient_volume_slider_value_changed(value):
	_set_volume(ambient_index, value)


func _on_music_volume_slider_value_changed(value):
	_set_volume(music_index, value)


func _on_sfx_volume_slider_value_changed(value):
	_set_volume(sfx_index, value)
