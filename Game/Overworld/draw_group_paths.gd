extends ImmediateGeometry


func _ready():
	set_process(true)

func _process(delta):
	var groups = get_tree().get_nodes_in_group("OverworldGroup")
	clear()
	for g in groups:
		if g.state == g.TRAVELLING:
			begin(Mesh.PRIMITIVE_LINE_STRIP)
			add_vertex(g.surface_pos)
			var steps = (g.travel_distance - g.travel_progress) * 100
			for i in range(steps):
				i /= 100.0
				add_vertex(g.vector_slerp(g.travel_start, g.travel_goal, (i+g.travel_progress)/g.travel_distance))
			add_vertex(g.travel_goal)
			end()
