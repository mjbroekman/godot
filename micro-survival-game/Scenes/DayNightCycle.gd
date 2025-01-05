extends Node3D

@export_category("Time Variables")
# 0 = midnight
# 0.5 = noon
var time : float
# Real seconds per day 
@export_range(10,3600,1) var day_length : float = 20.0
# Starting 'time' of the game (based on time var)
# 0.3 ~ 7am
@export_range(0,1,0.01) var start_time : float = 0.3
# time rate - convert day length into a rate that can be added to time
@export var time_rate : float

@export_category("Light Variables")
# sun variables
var sun : DirectionalLight3D
@export var sun_color : Gradient
@export var sun_intensity : Curve
# moon variables
var moon : DirectionalLight3D
@export var moon_color : Gradient
@export var moon_intensity : Curve
# world environment
var world : WorldEnvironment
@export var sky_top_color : Gradient
@export var sky_hor_color : Gradient

func _ready():
	time_rate = 1.0 / day_length
	time = start_time
	sun = get_node("SunLight")
	moon = get_node("Moon")
	world = get_node("WorldEnvironment")


func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		time += time_rate * delta
		if time >= 1.0:
			time = 0.0
		
		sun.rotation_degrees.x = time * 360 + 90
		sun.light_color = sun_color.sample(time)
		sun.light_energy = sun_intensity.sample(time)

		moon.rotation_degrees.x = time * 360 + 270
		moon.light_color = moon_color.sample(time)
		moon.light_energy = moon_intensity.sample(time)

		sun.visible = (sun.light_energy > 0)
		moon.visible = !sun.visible

		world.environment.sky.sky_material.set("sky_top_color",sky_top_color.sample(time))
		world.environment.sky.sky_material.set("sky_horizon_color",sky_hor_color.sample(time))
		world.environment.sky.sky_material.set("ground_bottom_color",sky_top_color.sample(time))
		world.environment.sky.sky_material.set("ground_horizon_color",sky_hor_color.sample(time))
