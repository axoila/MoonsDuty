extends Spatial

export(float) var radius
onready var __base_vector = Vector3(0, -radius, 0)

onready var surface_pos = get_translation()

onready var state = IDLE

export(float) var travel_speed = 1 #travel speed in radians
onready var travel_start = surface_pos #quaternion where to start
onready var travel_goal = surface_pos #quaternion where to go
var travel_distance = 0
var travel_progress = 0
var travel_prev_progress = 0
var travel_adjacient_length = 0
var travel_omega = 0
var travel_sin_o = 0

var IDLE = 0
var TRAVELLING = 1

func _ready():
	set_fixed_process(true)
	set_translation(surface_pos)
	get_node("Area").connect("area_enter", self, "collision")

func _fixed_process(delta):
	if state == TRAVELLING:
		travel_prev_progress = travel_progress
		travel_progress += delta * travel_speed
		if(travel_progress >= travel_distance):
			travel_progress = travel_distance
			surface_pos = travel_goal
			state = IDLE
		surface_pos = vector_slerp(travel_start, travel_goal, travel_progress/travel_distance)


	set_translation(surface_pos)
	look_at(Vector3(), Vector3(0, 1, 0))

func collision(area):
	if area.get_groups().has("Obstructing"):
		state = IDLE
		travel_progress = travel_prev_progress
		surface_pos = vector_slerp(travel_start, travel_goal, travel_progress/travel_distance)


func set_goal(pos):
	if surface_pos.distance_squared_to(pos) > 0.1:
		travel_goal = pos.normalized() * radius
		travel_start = surface_pos.normalized() * radius
		travel_distance = get_translation().angle_to(pos)
		travel_progress = 0
		travel_adjacient_length = pos.linear_interpolate(travel_start, 0.5).length()
		travel_omega = acos(travel_start.normalized().dot(travel_goal.normalized()))
		travel_sin_o = sin(travel_omega)
		state = TRAVELLING

func select():
	get_node("SpotLight").show()

func unselect():
	get_node("SpotLight").hide()

func vector_slerp(vec1, vec2, t):
	var foo = (sin((1 - t) * travel_omega) / travel_sin_o) * vec1
	var bar = (sin(t * travel_omega) / travel_sin_o) * vec2
	return foo + bar

func vec_to_rot(vec):
	var t = atan(vec.y / vec.x)
	var p = acos(vec.z / vec.length())
	return Vector3(0, t, p)




