extends EquipObject

@export var damage : int = 5
@export var attack_rate : float = 0.7
var last_attack_time : float

@onready var hit_collider : Area3D = get_node("HitCollider")

func on_primary_use ():
	if !can_attack():
		return
	
	last_attack_time = Time.get_unix_time_from_system()
	animation.stop()
	animation.play("Attack")

func on_hit ():
	var bodies = hit_collider.get_overlapping_bodies()
	
	for body in bodies:
		if player == body:
			continue
		
		if body.has_node("Health"):
			body.get_node("Health").take_damage(damage)

func can_attack () -> bool:
	return Time.get_unix_time_from_system() - last_attack_time > attack_rate
