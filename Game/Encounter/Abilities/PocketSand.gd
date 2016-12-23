extends Area

var init = false
var timer = 0
var life_time = 0.5
var damage = 5

var team = 0

var cast_time = 0.5

func _ready():
	set_process(true)

func _process(delta):
	timer += delta
	if timer > delta && !init && is_inside_tree():
		init()
	if timer > life_time:
		delete()
	
func init():
	init = !init
	get_node("Particles").set_emitting(true)
	for unit in get_overlapping_bodies():
		if unit.is_in_group("HostileUnit"):
			unit.damage(damage)
	if get_node("CollisionShape").is_inside_tree():
		get_node("CollisionShape").queue_free()
	
func delete():
	queue_free()