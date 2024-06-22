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


func _get_volume(bus_index : int) -> float:
	var db_volume = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db_volume)


func _set_volume(bus_index : int, volume : float):
	var db_volume = linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, db_volume)
