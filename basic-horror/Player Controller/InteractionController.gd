extends RayCast3D

# Each interactable object must extend from InteractableObject

@onready var interact_prompt_label : Label = get_node("InteractionPrompt")

func _process(delta):
	# Get the object we're currently looking at.
	var object = get_collider()
	
	interact_prompt_label.text = ""
	
	# Is it an interactable object?
	if object and object is InteractableObject:
		# Return if we cannot interact with this object.
		if object.can_interact == false:
			return
		
		# Set the interact prompt label.
		interact_prompt_label.text = "[E] " + object.interact_prompt
		
		# Interact when we press the button.
		if Input.is_action_just_pressed("interact"):
			object._interact()
