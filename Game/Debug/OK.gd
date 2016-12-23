extends Button

func _ready():
	connect("button_up", self, "press")

func press():
	get_tree().set_pause(false)
	get_node("../").hide()
