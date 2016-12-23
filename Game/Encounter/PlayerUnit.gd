extends "BaseUnit.gd"

export(PackedScene) var ability1
export(PackedScene) var ability2

var casting = -1
var ability_current = null
var ability_preview = null
var ability_core = null

func _ready():
	get_node("HPBar").max_health = health
	get_node("HPBar").health = health
	
	add_to_group("Friendly")

func set_goal(pos):
	if casting >= 0:
		ability_cancel()
	else:
		.set_goal(pos)

func damage(damage_amount):
	.damage(damage_amount)
	get_node("HPBar").health = health

func start_ability_cast():
	get_tree().set_pause(true)
	stop()

func finish_ability_cast(index):
	if get_tree().is_paused():
		casting = index
		if index == 0:
			ability_current = ability1.instance()
		elif index ==1:
			ability_current = ability2.instance()
		else:
			return
		ability_preview = ability_current.get_node("Preview")
		ability_core = ability_current.get_node("Ability")
		ability_current.remove_child(ability_preview)
		ability_current.remove_child(ability_core)
		add_child(ability_preview)
		ability_preview.set_translation(Vector3())

func ability_confirm():
	if casting > -1:
		ability_preview.queue_free()
		add_child(ability_core)
		ability_core.set_translation(Vector3())
		
		set_state(CASTING)
		cast_time = ability_core.cast_time
		casting = -1

func ability_cancel():
	if casting > -1:
		ability_preview.queue_free()
		ability_current = null
		ability_core = null
		ability_preview = null
		get_tree().set_pause(true)
		casting = -1

func set_state(value):
	.set_state(value)
	if selected:
		if value == IDLE:
			get_tree().set_pause(true)
		elif value == TRAVELLING:
			get_tree().set_pause(false)
		elif value == CASTING:
			get_tree().set_pause(false)
		else:
			printerr("unimplemented state?")


