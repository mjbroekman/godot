class_name SpawnableAgent
extends Node

@export var agent_scene : PackedScene
@export var max_in_world : int = 10
var current_agents = []

func remove_null_agents():
	for agent in current_agents:
		if not is_instance_valid(agent):
			current_agents.erase(agent)
