tool
extends Particles

export(float) var delay = 1

var __timer = 0

func _ready():
	set_process(true)

func _process(delta):
	__timer += delta
	if __timer > delay:
		__timer = 0
		set_emitting(true)
