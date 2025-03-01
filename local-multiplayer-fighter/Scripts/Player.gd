extends CharacterBody2D

@export var move_speed : float = 600.0
@export var jump_force : float = 1000.0
@export var gravity : float = 2800.0
@export var fireball : PackedScene = preload("res://Scenes/Projectile.tscn")

var char_dir : float = 0.0
var player : String = ""
var controls : Dictionary
var can_shoot : bool = true


func _ready():
	if Global.keybindings.has(name):
		print("Using keybindings for " + name)
		player = name
	
	if name == "Player":
		print("Defaulting to controls for player 1")
		player = "Player1"

	if name == "Player2":
		get_node("PlayerSprite").flip_h = true

	if name == "":
		print("Error... Player node name not discoverable. Exiting...")
		get_tree().quit()

	controls = Global.keybindings[player]
	reset_player()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		get_node("PlayerSprite").play("Jump")

	if Input.is_action_just_pressed(controls["fire"]):
		shoot_projectile()

	# Handle jump.
	if is_on_floor() and ( Input.is_action_just_pressed(controls["jump"]) ):
		velocity.y -= jump_force

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
	if player == "Player1":
		position = get_parent().get_node("SpawnPoints/LeftSpawn").position
	if player == "Player2":
		position = get_parent().get_node("SpawnPoints/RightSpawn").position


func shoot_projectile():
	if can_shoot:
		var fireball_inst : Area2D = fireball.instantiate()
		fireball_inst.position = self.position

		if get_node("PlayerSprite").flip_h:
			fireball_inst.proj_dir = -1
		else:
			fireball_inst.proj_dir = 1

		get_parent().add_child(fireball_inst)

	can_shoot = false


func _on_attack_rate_timer_timeout():
	can_shoot = true
