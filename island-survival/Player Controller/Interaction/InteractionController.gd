extends RayCast3D

@onready var interact_prompt_label : Label = get_node("InteractionPrompt")

func _process(delta):
	var object = get_collider()
	interact_prompt_label.text = ""
	
	if object and object is InteractableObject:
		if object.can_interact == false:
			return
		
		interact_prompt_label.text = "[E] " + object.interact_prompt
		
		if Input.is_action_just_pressed("interact"):
			object._interact()
