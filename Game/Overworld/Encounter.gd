extends Area

export(float) var encounter_cooldown
export(float) var probability = .1

var local_groups = []
var __cooldown = 0

func _ready():
	set_fixed_process(true)
	connect("area_enter", self, "group_enter")
	connect("area_exit", self, "group_leave")
	
func _fixed_process(delta):
	__cooldown -= delta
	for group in local_groups:
		if __cooldown < 0 && rand_range(0, 1) < probability * delta:
			get_tree().change_scene("res://Encounter/Encounter.tscn")
#			__cooldown = encounter_cooldown
#			get_node("/root/Spatial/UI/Panel").show()
#			get_tree().set_pause(true)

func group_enter(area):
	if area.get_parent().get_groups().has("OverworldGroup"):
		local_groups.append(area.get_parent())
		
func group_leave(area):
	if area.get_parent().get_groups().has("OverworldGroup"):
		local_groups.erase(area.get_parent())
