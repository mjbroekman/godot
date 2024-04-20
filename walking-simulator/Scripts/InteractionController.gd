extends RayCast3D

@onready var interact_prompt_label : Label = get_node("InteractionPrompt")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var object = get_collider()
	interact_prompt_label.text = ""
	
	if object and object is InteractableObject:
		pass
