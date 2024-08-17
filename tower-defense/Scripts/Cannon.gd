extends StaticBody3D
class_name Cannon

@export_category("Ammunition")
@export var bullet : PackedScene
@export var bullet_damage : int = 1

var targets : Array[CharacterBody3D] = []
var current : CharacterBody3D
var can_shoot : bool = true

@onready var tower_name : String = self.scene_file_path.split("/")[-1].split(".")[0].capitalize()
@onready var barrels : Array[Node] = get_node("MeshInstance3D").find_children("AimPoint*")

var cost : int:
	get():
		return cost
	set(value):
		cost = value

var last_barrel : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	$ShootingCooldown.wait_time = $ShootingCooldown.wait_time / barrels.size()
	cost = 200 + ( (barrels.size() - 1) * 400 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (bullet == null):
		load_bullets()

	if is_instance_valid(current):
		look_at(current.global_position)
		if can_shoot:
			fire()
			can_shoot = false
			$ShootingCooldown.start()
	else:
		for b in get_node("BulletContainer").get_child_count():
			get_node("BulletContainer").get_child(b).queue_free()

func load_bullets():
	print("Loading default bullets for a " + tower_name)
	if (tower_name == "Cannon"):
		bullet = load("res://Objects/Bullets/single_bullet.tscn")
	elif (tower_name == "Blaster"):
		bullet = load("res://Objects/Bullets/blaster_bolt.tscn")
	else:
		queue_free()

	if (bullet != null):
		print(tower_name + ": " + bullet.resource_path)



func _on_mob_detector_body_entered(body):
	if body.is_in_group("Enemy"):
		targets.append(body)
	
	chooseTarget(targets)


func _on_mob_detector_body_exited(body):
	if body.is_in_group("Enemy"):
		targets.erase(body)

	chooseTarget(targets)


func chooseTarget(target_list : Array[CharacterBody3D]):
	var temp_array : Array = target_list
	var current_target : CharacterBody3D = null

	for i in temp_array:
		if current_target == null:
			current_target = i
		else:
			if i.get_parent().progress > current_target.get_parent().progress:
				current_target = i

	current = current_target


func fire() -> void:
	if can_shoot:
		last_barrel += 1
		last_barrel = last_barrel % barrels.size()
		var barrel_to_use = barrels[last_barrel]

		var temp_bullet : CharacterBody3D = bullet.instantiate()
		temp_bullet.target = current
		temp_bullet.bullet_damage = bullet_damage
		temp_bullet.speed = 50
		get_node("BulletContainer").add_child(temp_bullet)
		temp_bullet.global_position = barrel_to_use.global_position


func _on_shooting_cooldown_timeout():
	can_shoot = true
