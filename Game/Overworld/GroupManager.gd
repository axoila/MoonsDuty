extends Camera

export(NodePath) var selection_box

onready var selected = []

var __mousepos = Vector2()
var __send = false

var __box_start = Vector2(0, 0)
var __selecting = false

func _ready():
	set_process_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	if __send:
		var space_state = get_world().get_direct_space_state()
		var result = space_state.intersect_ray(project_ray_origin(__mousepos), project_ray_origin(__mousepos) + project_ray_normal(__mousepos) * 100)
		
		if !result.empty() && selected != null:
			for sel in selected:
				sel.set_goal(result.position)
				
			__send = false

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.pressed:
			if event.button_index == BUTTON_RIGHT:
				__mousepos = event.pos
				__send = true
			
			if event.button_index == BUTTON_LEFT:
				start_selection(event.pos)
		else:
			if event.button_index == BUTTON_LEFT:
				end_selection(event.pos)
	if event.type == InputEvent.MOUSE_MOTION:
		update_selection(event.pos)

func start_selection(pos):
	get_node(selection_box).show()
	get_node(selection_box).set_begin(pos)
	get_node(selection_box).set_end(pos)
	__selecting = true
	__box_start = pos
	
	
func end_selection(pos):
	get_node(selection_box).set_begin(Vector2(min(__box_start.x, pos.x), min(__box_start.y, pos.y)))
	get_node(selection_box).set_end(Vector2(max(__box_start.x, pos.x), max(__box_start.y, pos.y)))
	get_node(selection_box).hide()
	__selecting = false
	for s in selected:
		s.unselect()
	selected.clear()
	var rect = get_node(selection_box).get_rect()
	var selectable = get_tree().get_nodes_in_group("OverworldGroup")
	if rect.get_area() > 4:
		for s in selectable:
			print(get_global_transform().origin.dot(s.get_translation()))
			if rect.has_point(unproject_position(s.get_translation())) \
					&& get_global_transform().origin.dot(s.get_translation()) > 0:
				s.select()
				selected.append(s)
	else:
		var min_prox = -1
		for s in selectable:
			if (min_prox < 0 || pos.distance_to(unproject_position(s.get_translation())) < min_prox) \
					&& pos.distance_to(unproject_position(s.get_translation())) < 100\
					&& get_global_transform().origin.dot(s.get_translation()) > 0:
				min_prox = pos.distance_to(unproject_position(s.get_translation()))
				selected.clear()
				selected.append(s)
		if selected.size() != 0:
			selected[0].select()
	
	

func update_selection(pos):
	if __selecting:
		get_node(selection_box).set_begin(Vector2(min(__box_start.x, pos.x), min(__box_start.y, pos.y)))
		get_node(selection_box).set_end(Vector2(max(__box_start.x, pos.x), max(__box_start.y, pos.y)))
