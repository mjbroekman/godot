extends ProgressBar

@export var need_name : String
@export var need_color : Color

@onready var text : Label = get_node("NeedText")
var style : StyleBoxFlat

func _ready():
	need_name = get_parent().name
	print(get_parent().name)
	if need_name == "Health":
		need_color = Color.CRIMSON
	
	if need_name == "Hunger":
		need_color = Color.WEB_GREEN
	
	if need_name == "Thirst":
		need_color = Color.MEDIUM_BLUE
	
	if need_name == "Sleep":
		need_color = Color.DARK_GOLDENROD

	print(need_color)
	style = get_theme_stylebox("fill")


func update_value(new_value, need_max):
	max_value = need_max
	value = new_value
	text.text = str(need_name, " : ", int(value) , " / " , int(max_value) )
	style.bg_color = need_color
