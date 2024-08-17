extends ProgressBar


func setup_bar(amount : int) -> void:
	self.max_value = amount
	self.value = amount

func update_bar(amount : int) -> void:
	self.value = amount
