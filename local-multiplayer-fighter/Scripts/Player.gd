extends CharacterBody2D

@export var move_speed : float = 600.0
@export var jump_force : float = 1000.0
@export var gravity : float = 2800.0
@export var fireball : PackedScene = preload("res://Scenes/Projectile.tscn")
@export var ui_ctrl : Control
@export var player_health_ui : ProgressBar
@export var player_score_ui : Label
@export var death_bloom : PackedScene = preload("res://Scenes/DeathBlossom.tscn")

var char_dir : float = 0.0
var player : String = ""
var opponent : String = ""
var opp_cb2d : CharacterBody2D
var max_health : float = 3.0
var controls : Dictionary
var can_shoot : bool = true
var device : int = -1
var proj_color : Color = Color.BLUE
var death_color : Color = Color.GREEN
var player_color : Color = Color.RED
var player_sprite : AnimatedSprite2D
var is_dead : bool = false
var ui : Control

func _ready():
	var devices : Array[int] = Input.get_connected_joypads()
	player_sprite = get_node("PlayerSprite")
	ui = get_parent().get_node("UI")

	if Global.keybindings.has(name):
		player = name
	
	if name == "Player" or name == "Player1":
		player = "Player1"
		opponent = "Player2"
		if Global.player1_colors.size() > 0:
			player_color = Global.player1_colors[0]
			proj_color = Global.player1_colors[1]
			death_color = Global.player1_colors[2]

		if devices.size() > 0:
			device = 0
		else:
			device = -1

	if name == "Player2":
		get_node("PlayerSprite").flip_h = true
		opponent = "Player1"
		if Global.player2_colors.size() > 0:
			player_color = Global.player2_colors[0]
			proj_color = Global.player2_colors[1]
			death_color = Global.player2_colors[2]

		if devices.size() > 1:
			device = 1
		else:
			device = -1

	if name == "":
		print("Error... Player node name not discoverable. Exiting...")
		get_tree().quit()

	opp_cb2d = get_parent().get_node(opponent)
	player_sprite.modulate = player_color

	player_health_ui = get_parent().get_node("UI/UIBanner/"+ player + "UI/ProgressBar")
	var player_health_stylebox = player_health_ui.get_theme_stylebox("fill").duplicate()
	player_health_stylebox.bg_color = player_color
	player_health_ui.add_theme_stylebox_override("fill", player_health_stylebox)

	player_score_ui = get_parent().get_node("UI/UIBanner/"+ player + "UI/ScoreLabel")

	controls = Global.keybindings[player]

	reset_player()


func decrease_health():
	if not is_dead:
		player_health_ui.value -= 1

		if player_health_ui.value <= 0:
			death()


func death():
	self.is_dead = true

	# Hide the player
	self.visible = false

	# Trigger the gibbity bits
	var death_blossom : CPUParticles2D = death_bloom.instantiate()
	get_parent().add_child(death_blossom)
	death_blossom.position = self.position
	death_blossom.color = death_color

	# If we died from falling, put the gibs at the bottom of the screen
	if death_blossom.position.y > get_viewport_rect().size.y:
		death_blossom.position.y = get_viewport_rect().size.y

	# Start the gibbity bits
	death_blossom.emitting = true

	# Wait for the gibbity bits to die down
	await get_tree().create_timer(0.5).timeout

	# Clear the field of projectiles
	for pnode in get_tree().get_nodes_in_group("Projectile"):
		pnode.queue_free()

	# Increase the score of the player that shot us
	opp_cb2d.increase_score()

	# Reset everyone for the next round
	reset_player()
	opp_cb2d.reset_player()


func increase_score():
	player_score_ui.text = str(int(player_score_ui.text) + 1)
	if Global.game_mode == Global.game_modes.SingleMatch:
		ui.game_finished(player)
	
	if Global.game_mode == Global.game_modes.Championship:
		if int(player_score_ui.text) > (Global.championship / 2):
			ui.game_finished(player)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		get_node("PlayerSprite").play("Jump")

	if ( Input.is_action_just_pressed(controls["fire"]) or MultiplayerInput.is_action_just_pressed(device,"shoot_ctlr") ):
		shoot_projectile()

	# Handle jump.
	if is_on_floor() and ( Input.is_action_just_pressed(controls["jump"]) or MultiplayerInput.is_action_just_pressed(device,"jump_ctlr") ):
		velocity.y -= jump_force

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	char_dir = 0
	if Input.get_axis(controls["left"], controls["right"]) != 0:
		char_dir = Input.get_axis(controls["left"], controls["right"])
	elif MultiplayerInput.get_axis(device, "move_left_ctlr", "move_right_ctlr"):
		char_dir = MultiplayerInput.get_axis(device, "move_left_ctlr", "move_right_ctlr")

	char_dir = Input.get_axis(controls["left"], controls["right"])
	if char_dir > 0:
		get_node("PlayerSprite").flip_h = false
	if char_dir < 0:
		get_node("PlayerSprite").flip_h = true

	if char_dir:
		velocity.x = char_dir * move_speed
		get_node("PlayerSprite").play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		get_node("PlayerSprite").play("Idle")

	move_and_slide()

	if position.y > 1000:
		reset_player()
	if position.x < 0:
		position.x = 0
	if position.x > get_viewport_rect().size.x:
		position.x = get_viewport_rect().size.x


func reset_player():
	player_health_ui.value = max_health
	self.visible = true
	self.is_dead = false

	if player == "Player1":
		position = get_parent().get_node("SpawnPoints/LeftSpawn").position
	if player == "Player2":
		position = get_parent().get_node("SpawnPoints/RightSpawn").position


func shoot_projectile():
	if can_shoot and not opp_cb2d.is_dead:
		var fireball_inst : Area2D = fireball.instantiate()
		fireball_inst.player = player
		fireball_inst.position = self.position
		fireball_inst.set_color(proj_color)
		fireball_inst.get_node("Particles").color = proj_color

		if get_node("PlayerSprite").flip_h:
			fireball_inst.proj_dir = -1
			fireball_inst.get_node("Particles").gravity *= -1
		else:
			fireball_inst.proj_dir = 1

		get_parent().add_child(fireball_inst)

	can_shoot = false


func _on_attack_rate_timer_timeout():
	can_shoot = true
