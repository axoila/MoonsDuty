extends KinematicBody

var selected = false

 #movement stuff
export(NodePath) var navigation
export(float) var speed
var goal = Vector3()
var path

 #state stuff
onready var state = IDLE setget set_state
enum {IDLE, TRAVELLING, CASTING}
var cast_time = 0

onready var team = FRIENDLY
enum {FRIENDLY, HOSTILE}

 #resources
var health = 20

 #recording
var position_time
var rotation_time
var health_time
var time_pos = 0 setget set_time
var furthest_time = 0

signal reached_goal

func _ready():
	set_fixed_process(true)
	position_time = Vector3Array([get_translation()])
	rotation_time = Vector3Array([get_rotation()])
	health_time = IntArray([health])
	# set up the arrays so the size is clear and now only work with set never append
	for i in range(get_parent().time_span-1):
		position_time.append(Vector3())
		rotation_time.append(Vector3())
		health_time.append(-1)

func _fixed_process(delta):
	#movement
	if state == TRAVELLING:
		path = get_node(navigation).get_simple_path(get_translation(), goal)
		var motion = path[1] - get_translation()
		if motion.length() < speed * delta:
			if path.size() == 2:
				move_to(path[1])
				set_state(IDLE)
				emit_signal("reached_goal")
			elif !get_tree().is_paused():
				move(motion.normalized() * speed * delta)
		elif !get_tree().is_paused():
			move(motion.normalized() * speed * delta)
		if motion.length() > 0.1:
			look_at(path[1], Vector3(0, 1, 0))
	
	if state == CASTING:
		cast_time -= delta
		if cast_time < 0:
			set_state(IDLE)
	
	#recording
	if !get_tree().is_paused() && selected:
		furthest_time = time_pos + 1
		time_pos = time_pos + 1
		position_time[time_pos] = get_translation()
		rotation_time[time_pos] = get_rotation()
		health_time[time_pos] = health
		get_parent().set_time(get_parent().time_pos + 1)

func set_goal(pos):
	goal = pos
	set_state(TRAVELLING)

func stop():
	state = IDLE

func damage(damage_amount):
	health -= damage_amount
	furthest_time = time_pos
	health_time[time_pos] = health
	print(str(health,"HP left"))

func select():
	get_node("Selected").show()
	selected = true
	set_state(state)

func deselect():
	get_node("Selected").hide()
	selected = false

func set_state(value):
	state = value

func set_time(value):
	if value > furthest_time:
		if selected:
			time_pos = furthest_time
		else:
			time_pos = furthest_time
	elif value >= 0:
		time_pos = value
	else:
		time_pos = 0
	set_translation(position_time[time_pos])
	set_rotation(rotation_time[time_pos])
	health = health_time[time_pos]
	
	return time_pos





