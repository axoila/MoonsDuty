extends ImmediateGeometry


func _ready():
	set_process(true)

func _process(delta):
	var groups = get_tree().get_nodes_in_group("PlayerUnit")
	clear()
	for g in groups:
		if g.state == g.TRAVELLING:
			begin(Mesh.PRIMITIVE_LINE_STRIP)
			for point in g.path:
				add_vertex(point+Vector3(0, 0.1, 0))
			end()
