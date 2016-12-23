extends Spatial

export(float) var mouse_acceleration = 1

export(float) var x_rot = 0
export(float) var y_rot = 0
export(float) var base_distance = 10
export(float) var distance = 10
export(float) var zoom_modifier = 0.9

var mouse_speed = Vector2()
var mouse_moving = false # 0 is no mouse, 2 is ready to read
var old_mouse_pos = Vector2()

func _ready():
	set_process_input(true)
	set_process(true)
	
	set_values()

func _process(delta):
	if mouse_moving && (Input.is_mouse_button_pressed(3)):
		x_rot -= (mouse_speed.y * delta) * mouse_acceleration
		if fposmod(x_rot + 90,360) <= 180:
			y_rot -= (mouse_speed.x * delta) * mouse_acceleration
		else:
			y_rot += (mouse_speed.x * delta) * mouse_acceleration
		set_values()
	mouse_moving = false

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		mouse_speed = event.pos - old_mouse_pos
		old_mouse_pos = event.pos
		mouse_moving = true
	
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_WHEEL_UP:
			distance = distance * zoom_modifier
		elif event.button_index == BUTTON_WHEEL_DOWN:
			distance = distance / zoom_modifier
		set_values()

func set_values():
	set_rotation_deg(Vector3(0, y_rot, 0))
	get_node("X_rot").set_rotation_deg(Vector3(x_rot, 0, 0))
	get_node("X_rot/Camera").set_translation(Vector3(0, 0, base_distance + distance))