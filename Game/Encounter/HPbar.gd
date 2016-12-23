extends Spatial

var health setget set_health
var max_health setget set_max_health


func _ready():
	set_process(true)

func _process(delta):
	get_node("Control").set_pos(get_viewport().get_camera().unproject_position(get_global_transform().origin))

func set_health(value):
	health = value
	get_node("Control/ProgressBar").set_value(health)
	update_text()

func set_max_health(value):
	max_health = value
	get_node("Control/ProgressBar").set_max(value)
	update_text()

func update_text():
	get_node("Control/ProgressBar/Label").set_text(str(health, " / ", max_health))