extends Control

onready var navigation : Navigation2D = get_tree().get_root().get_node("Node2D/Navigation2D")
onready var bunny = get_tree().get_root().get_node("Node2D/Sprite")

var path
func _ready():
	pass
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and not event.pressed:
			path = navigation.get_simple_path(bunny.position, get_global_mouse_position())
			bunny.path = path
			#update()

func update_draw():
	update()
	
func _draw():
	#Draw path
	if path:
		for i in path.size():
			draw_circle(path[i], 15, Color(1,0,0))
	#Draw nodes
	for i in $"..".graph_nodes.size():
		draw_circle($"..".graph_nodes[i],10,Color(0,0,0))
		draw_string(get_font("font"),$"..".graph_nodes[i], str(i))
	
	#Draw connections
	if $"..".draw_connection:
		for i in $"..".connect_points.size():
			for b in $"..".connect_points[i].size():
				draw_line($"..".graph_nodes[i], $"..".connect_points[i][b], Color(1,0,0), 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
