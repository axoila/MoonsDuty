extends Spatial

var selected = null

 #communication from input to fixedprocess
var __select = false
var __send = false
var __look = false
var __mouse_pos = Vector2(0, 0)

 #save the space state because it can't be read in paused mode
onready var space_state = get_world().get_direct_space_state()

var time_pos = 0
const time_span = 10 * 60

func _ready():
	set_process_input(true)
	set_fixed_process(true)
	
	get_tree().set_pause(true)
	
	get_node("UI").set_max_time(10 * 60.0) #10 seconds of 60 fps
	
	get_node("UI").connect("ability_pressed", self, "ability_pressed")
	get_node("UI").connect("ability_released", self, "ability_released")

func _fixed_process(delta):
	#follow the selected unit
	if selected != null:
		get_node("Camera").look_at(selected.get_translation(), Vector3(0, 1, 0))
	
	#if a message is sent hete
	if __select || __send || __look:
		if !get_tree().is_paused():
			space_state = get_world().get_direct_space_state()
		var ray_origin = get_node("Camera").project_ray_origin(__mouse_pos)
		var ray_dir = get_node("Camera").project_ray_normal(__mouse_pos)
		var result = space_state.intersect_ray(ray_origin, ray_origin + ray_dir * 100)
		#left click
		if __select:
			if !result.empty() && result.collider.get_groups().has("PlayerUnit"):
				if selected != null:
					selected.deselect()
					selected.ability_cancel()
				selected = result.collider
				selected.select()
				set_time(time_pos)
			elif selected != null && selected.casting > -1:
				selected.ability_confirm()
			__select = false
		#right click press and drag
		if __send:
			if get_tree().is_paused():
				if !result.empty() && selected != null:
					selected.set_goal(result.position)
			else:
				if selected:
					selected.ability_cancel()
			__send = false
		#mouse move while casting
		if __look:
			if !result.empty() && selected != null:
				selected.look_at(result.position * Vector3(1, 0, 1), Vector3(0, 1, 0))
			__look = false

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_WHEEL_UP:
			set_time(time_pos + 5)
		if event.button_index == BUTTON_WHEEL_DOWN:
			set_time(time_pos - 5)
		
		
		
	
		if event.button_index == BUTTON_LEFT  && event.pressed:
			__select = true
			__mouse_pos = event.pos
	
	if event.type == InputEvent.MOUSE_BUTTON || event.type == InputEvent.MOUSE_MOTION:
		if Input.is_mouse_button_pressed(2):
			__send = true
			__mouse_pos = event.pos
		if selected && selected.casting >= 0:
			__look = true
			__mouse_pos = event.pos

func ability_pressed(index):
	if selected != null:
		selected.start_ability_cast()

func ability_released(index):
	if selected != null:
		selected.finish_ability_cast(index)

func set_time(time):
	if time >= 0 && time <= time_span:
		if selected != null:
			if time <= selected.furthest_time:
				time_pos = time
			else:
				time_pos = selected.furthest_time
	elif time < 0:
		time_pos = 0
	else:
		time_pos = time_span
	get_node("UI").set_time(time_pos)
	for unit in get_tree().get_nodes_in_group("Unit"):
		unit.set_time(time_pos)









