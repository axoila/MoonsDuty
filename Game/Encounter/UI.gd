extends Control

signal ability_pressed(index)
signal ability_released(index)

export(Vector2) var time_start
export(Vector2) var time_end
var max_time setget set_max_time
var time setget set_time

func _ready():
	set_fixed_process(true)
	
	var button_container = get_node("Panel2/CenterContainer/HBoxContainer")
	for i in range(2):
		button_container.get_node(str("Button", i)).connect("button_down", self, "emit_signal", ["ability_pressed",i])
		button_container.get_node(str("Button", i)).connect("button_up", self, "emit_signal", ["ability_released",i])

func _fixed_process(delta):
	if get_tree().is_paused():
		get_node("icon").show()
	else:
		get_node("icon").hide()

func set_max_time(value):
	max_time = value

func set_time(value):
	time = value
	get_node("Panel/TextureFrame").set_pos(time_start.linear_interpolate(time_end, time / max_time))