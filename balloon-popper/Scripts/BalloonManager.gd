extends Node3D

# local variables
var player_score : int = 0
var save_file : String = "user://BalloonPopper.save"
var balloon_file : PackedScene = load("res://Balloon.tscn")
var balloon_count : int = 5

# Exports
@export var score_text : Label
@export var high_score : Label
@export var remaining_balloons : Label

func increase_score(amount):
	player_score += amount
	print('Player now has a score of: %d !' % player_score)
	score_text.text = str("Score: %d" % player_score)

# Called when the node enters the scene tree for the first time.
func _ready():
	load_high_score()
	launch_balloons(balloon_file,balloon_count)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var num_balloons = get_tree().get_nodes_in_group("Balloons").size()
	remaining_balloons.text = str("Remaining balloons: %d" % num_balloons)
	if num_balloons == 0:
		var cur_data = get_game_data()
		write_save(cur_data)
		queue_free()
		# Be more elegant in the future with a menu... maybe?
		get_tree().quit()


func launch_balloons(balloon_node,num_balloons):
	var idx : int = 0
	
	while idx < num_balloons:
		var new_balloon = balloon_node.instantiate()
		add_child(new_balloon)
		new_balloon.add_to_group("Balloons")
		idx += 1

func write_save(cur_game):
	var saved_data = get_save_data()
	saved_data.append(cur_game)
	var json_string = JSON.stringify(saved_data)
	var save_game_file = FileAccess.open(save_file, FileAccess.WRITE)
	save_game_file.store_line(json_string)


func get_save_data():
	# Identify the saved data or instantiate it
	if not FileAccess.file_exists(save_file):
		return []

	var save_data = FileAccess.open(save_file, FileAccess.READ)

	# Load the file line by line and process that dictionary to restore
	# the objects it represents.
	while save_data.get_position() < save_data.get_length():
		var json_string = save_data.get_line()
		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		print(parse_result)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		print(node_data)

func load_high_score():
	pass
#	high_score.text = str("High Score: %d" % node_data[""])

func get_game_data():
	var save_dict = {
		"score": player_score,
		"date": Time.get_datetime_string_from_system()
	}
	return save_dict


