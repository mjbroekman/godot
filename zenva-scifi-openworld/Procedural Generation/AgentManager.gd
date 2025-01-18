extends Node3D

@onready var terrain_gen : TerrainGeneration = get_node("/root/Main/TerrainGeneration")
var agents : Array[SpawnableAgent]


func _ready():
	for child in get_children():
		if child is SpawnableAgent:
			agents.append(child)


func spawn_agents():
	for agent in agents:
		while agent.current_agents.size() < agent.max_in_world:
			spawn_agent(agent)


func spawn_agent(agent):
	var spawn_pos = terrain_gen.get_random_position()
	var map = get_world_3d().navigation_map
	var adjusted_spawn_pos = NavigationServer3D.map_get_closest_point(map, spawn_pos)

	var ai = agent.agent_scene.instantiate()
	ai.position = adjusted_spawn_pos
	add_child(ai)

	agent.current_agents.append(ai)

	print("Spawned agent: " + str(adjusted_spawn_pos))


func _on_timer_timeout():
	for agent in agents:
		agent.remove_null_agents()

		print("Agents in world = " + str(agent.current_agents.size()))

		while agent.current_agents.size() < agent.max_in_world:
			spawn_agent(agent)
