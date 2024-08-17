extends Node3D

@export_category("Spawnables")
@export var enemies : Array[PackedScene]
@export var total_spawn_time : float = 15

@export_category("Towers")
@export var towers : Array[PackedScene]


@onready var build_spot : MeshInstance3D = $BuildSpot
@onready var camera : Camera3D = $Camera3D

var can_spawn : bool = true
var rng = RandomNumberGenerator.new()
var in_build_menu : bool = false
var enemies_to_spawn : int
var spawn_timer_time : float
var is_upgrade : bool = false
var query : PhysicsShapeQueryParameters3D
var upgrade_complete : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	query = PhysicsShapeQueryParameters3D.new()
	query.shape = SeparationRayShape3D.new()
	$CanvasLayer/UI/GameOverPanel.visible = false
	_setup_wave()


func _setup_wave() -> void:
	print("Starting wave " + str(Global.wave) + " ...")
	enemies_to_spawn = _get_wave(Global.wave)
	spawn_timer_time = total_spawn_time / float(enemies_to_spawn)
	if spawn_timer_time < 0.2:
		spawn_timer_time = 0.2
	if spawn_timer_time > 2:
		spawn_timer_time = 2

	print("Spawning " + str(enemies_to_spawn) + " enemies for wave " + str(Global.wave))
	print("Enemies will spawn every " + str(spawn_timer_time) + " seconds")
	$SpawnTimer.wait_time = spawn_timer_time


func _get_wave(wave : int) -> int:
	if wave == 0 or wave == 1:
		return 1
	else:
		return _get_wave(wave - 1) + _get_wave(wave - 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	game_manager()
	handle_player_controls()


func game_over() -> void:
	$CanvasLayer/UI/GameOverPanel.visible = true

func game_manager() -> void:
	if Global.health <= 0:
		game_over()
	
	$Map/TowerRoundSampleF/HealthBar3D.update(Global.health)
	$CanvasLayer/UI/Money.text = "Gold: " + str(Global.money)
	$CanvasLayer/UI/Wave.text = "Wave: " + str(Global.wave)

	if enemies_to_spawn < 1 and Global.enemies_alive < 1:
		$CanvasLayer/UI/NextWaveButton.visible = true
	else:
		$CanvasLayer/UI/NextWaveButton.visible = false

	if enemies_to_spawn > 0 and can_spawn:
		$SpawnTimer.start()
		var temp_enemy = enemies[rng.randi_range(0,(enemies.size() - 1))].instantiate()
		$Path.add_child(temp_enemy)
		enemies_to_spawn -= 1
		can_spawn = false


func handle_player_controls() -> void:
	build_spot.visible = false
	$CanvasLayer/UI/ShopPanel.visible = in_build_menu

	# Includes adaptations from https://www.reddit.com/r/godot/comments/14dv28b/raycast_that_returns_an_array_of_collision_info/
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var ray_origin : Vector3 = camera.project_ray_origin(mouse_pos)

	var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var ray_end : Vector3 = ray_origin + camera.project_ray_normal(mouse_pos) * 100
	var ray : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	
	# Adjust per frame
	query.shape.length = ray_origin.distance_to(ray_end)
	query.transform.origin = ray_origin
	query.transform = query.transform.looking_at(ray_end, Vector3.UP, true) # If the direction is inversed change true to false

	#var ray_result : Dictionary = space_state.intersect_ray(ray)
	var ray_results = get_world_3d().direct_space_state.intersect_shape(query)

	if not in_build_menu:
		if ray_results.size() > 0:
			var collider : CollisionObject3D
			for result in ray_results:
				collider = result.get("collider")
				if collider.is_in_group("Tower"):
					is_upgrade = true
					break

			build_spot.global_position = collider.global_position + Vector3(0,0.2,0)

			if collider.is_in_group("Empty"):
				build_spot.visible = true
				build_spot.set_surface_override_material(0,load("res://Materials/green_material_3d.tres"))
				if Input.is_action_just_pressed("interact"):
					is_upgrade = false
					toggle_ui()

			elif collider.is_in_group("Tower"):
				build_spot.visible = true
				build_spot.set_surface_override_material(0,load("res://Materials/purple_material_3d.tres"))

				if Input.is_action_just_pressed("interact2"):
					recycle_object(collider)
			else:
				build_spot.set_surface_override_material(0,load("res://Materials/red_material_3d.tres"))
	else:
		if Input.is_action_just_pressed("ui_cancel"):
			toggle_ui()


func recycle_object(object) -> void:
	if object.tower_name == "Cannon":
		Global.update_money(190)
		object.queue_free()
	
	if object.tower_name == "Blaster":
		Global.update_money(570)
		object.queue_free()


func buy_tower(cost : int, tower : PackedScene) -> void:
	if ( Global.money >= cost ):
		Global.update_money(cost * -1)
		var temp_cannon : Cannon = tower.instantiate()
		temp_cannon.cost = cost
		add_child(temp_cannon)
		temp_cannon.global_position = build_spot.global_position + Vector3(0,0.1,0)
		upgrade_complete = true

	toggle_ui()


func toggle_ui() -> void:
	in_build_menu = not in_build_menu
	$CanvasLayer/UI/ShopPanel.visible = in_build_menu


func _on_spawn_timer_timeout():
	can_spawn = true


func _on_cannon_button_pressed():
	var cost = 200
	buy_tower(cost,towers[0])


func _on_blaster_button_pressed():
	var cost = 600
	buy_tower(cost,towers[1])


func _on_cancel_button_pressed():
	in_build_menu = false
	$CanvasLayer/UI/ShopPanel.visible = in_build_menu


func _on_next_wave_button_pressed():
	Global.wave += 1
	_setup_wave()


func _on_start_game_button_pressed():
	Global.reset()
	get_tree().reload_current_scene()


func _on_quit_button_pressed():
	get_tree().quit()
