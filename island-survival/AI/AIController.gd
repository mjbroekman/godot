class_name AIController
extends CharacterBody3D

@export var walk_speed : float = 1.0
@export var run_speed : float = 2.5
var running : bool = false
var is_stopped : bool = false
var look_at_player : bool = false

var move_direction : Vector3
var target_y_rot : float

@onready var agent : NavigationAgent3D = get_node("NavigationAgent3D")
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player : PlayerController = get_tree().get_nodes_in_group("Player")[0]

var player_distance : float

func _process(delta):
	if player:
		player_distance = position.distance_to(player.position)

func _physics_process(delta):
	# Stop the ai if player is far away.
	if player_distance > 30:
		return
	
	# Apply gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var target_pos = agent.get_next_path_position()
	var move_dir = global_position.direction_to(target_pos)
	move_dir.y = 0
	move_dir = move_dir.normalized()
	
	# Don't move if we're done with navigation or is stopped.
	if agent.is_navigation_finished() or is_stopped:
		move_dir = Vector3.ZERO
	
	var current_speed = walk_speed
	
	if running:
		current_speed = run_speed
	
	# Set velocity.
	velocity.x = move_dir.x * current_speed
	velocity.z = move_dir.z * current_speed
	
	# Rotate to velocity or player.
	if !look_at_player and velocity.length() > 0:
		target_y_rot = atan2(velocity.x, velocity.z)
	elif look_at_player:
		var player_dir = (player.position - position)
		target_y_rot = atan2(player_dir.x, player_dir.z)
	
	rotation.y = lerp_angle(rotation.y, target_y_rot, 0.1)
	
	move_and_slide()

func move_to_position (to_position : Vector3, adjust_pos : bool = true):
	if not agent:
		agent = get_node("NavigationAgent3D")
		
	is_stopped = false
	
	if adjust_pos:
		var map = get_world_3d().navigation_map
		var adjusted_to_position = NavigationServer3D.map_get_closest_point(map, to_position)
		agent.target_position = adjusted_to_position
	else:
		agent.target_position = to_position
