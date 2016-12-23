extends Spatial

export(float) var radius
onready var __base_vector = Vector3(0, -radius, 0)

onready var surface_rot = pos_to_quat(get_translation())

var state = "idle"

export(float) var travel_speed = 1 #travel speed in radians
onready var travel_start = surface_rot #quaternion where to start
onready var travel_goal = surface_rot #quaternion where to go
var travel_distance = 0
var travel_progress = 0
var travel_prev_progress = 0

func _ready():
	set_fixed_process(true)
	set_translation(quat_to_pos(surface_rot))
	get_node("Area").connect("area_enter", self, "collision")

func _fixed_process(delta):
	if state == "travelling":
		travel_prev_progress = travel_progress
		travel_progress += delta * travel_speed
		if(travel_progress >= travel_distance):
			travel_progress = travel_distance
			state = "idle"
		surface_rot = travel_start.slerp(travel_goal, travel_progress/travel_distance)
		
	
	set_translation(quat_to_pos(surface_rot))
	set_rotation(Matrix3(surface_rot).get_euler())

func collision(area):
	if area.get_groups().has("Obstructing"):
		state = "idle"
		travel_progress = travel_prev_progress
		surface_rot = travel_start.slerp(travel_goal, travel_progress/travel_distance)
		

func set_goal(pos):
	if pos.angle_to(quat_to_pos(surface_rot)) > 0.01:
		travel_goal = pos_to_quat(pos)
		travel_start = surface_rot
		travel_distance = get_translation().angle_to(pos)
		travel_progress = 0
		state = "travelling"

func select():
	get_node("OmniLight").show()

func unselect():
	get_node("OmniLight").hide()

func pos_to_quat(pos):
	return (Quat(__base_vector.cross(-pos), __base_vector.angle_to(pos)).normalized())

func quat_to_pos(quat):
	var pos = quat.xform(__base_vector)
	return pos