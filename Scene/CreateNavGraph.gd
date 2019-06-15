extends TileMap

onready var astar := AStar.new() 
onready var boundry = get_used_rect()
var graph_nodes := PoolVector2Array()
var space_state 
var get_connection = false
var draw_connection = false
var connect_points := []

const COLLISION_TILES := [-1,0]

func _ready():
	set_points()
	add_points(graph_nodes)
	get_connection = true #Triggers _physics_process 
	
#Add all collision vertices of tilemap to graph_nodes
func set_points():
	var tiles = get_used_cells()
		
	for i in tiles.size():
		var tile_id = get_cellv(tiles[i])
		if tile_id == 0:
			var collision_vertices = tile_set.tile_get_navigation_polygon(tile_id + 1).get_vertices()
			
			for vertex in collision_vertices:
				var new_vertex := Vector2()
				new_vertex.x = vertex.x/64 + tiles[i].x #Tileset to tilemap space
				new_vertex.y = vertex.y/64 + tiles[i].y #Tileset to tilemap space
				
				#Add vertices that one collision tile
				if not map_to_world(new_vertex) in graph_nodes:
					match vertex.normalized():
						Vector2(0,0): 
							if (not get_cellv(Vector2(new_vertex.x - 1, new_vertex.y - 1)) in COLLISION_TILES
							and not get_cellv(Vector2(new_vertex.x, new_vertex.y - 1)) in COLLISION_TILES
							and not get_cellv(Vector2(new_vertex.x -1, new_vertex.y)) in COLLISION_TILES):
								graph_nodes.append(map_to_world(new_vertex))
								
						Vector2(1,0): 
							if (not get_cellv(Vector2(new_vertex.x - 1, new_vertex.y - 1)) in COLLISION_TILES
							and not get_cellv(Vector2(new_vertex.x, new_vertex.y - 1)) in COLLISION_TILES
							and not get_cellv(new_vertex) in COLLISION_TILES):
								graph_nodes.append(map_to_world(new_vertex))
								
						Vector2(1/sqrt(2),1/sqrt(2)): 
							if (not get_cellv(Vector2(new_vertex.x, new_vertex.y - 1)) in COLLISION_TILES
							and not get_cellv(new_vertex) in COLLISION_TILES
							and not get_cellv(Vector2(new_vertex.x -1, new_vertex.y)) in COLLISION_TILES):
								graph_nodes.append(map_to_world(new_vertex))
								
						Vector2(0,1): 
							if (not get_cellv(Vector2(new_vertex.x - 1, new_vertex.y - 1)) in COLLISION_TILES
							and not get_cellv(new_vertex) in COLLISION_TILES
							and not get_cellv(Vector2(new_vertex.x -1, new_vertex.y)) in COLLISION_TILES):
								graph_nodes.append(map_to_world(new_vertex)) #Use mod to navigate in future
	
	#update()

func add_points(nodes : PoolVector2Array):
	for i in nodes:
		astar.add_point(get_point_id(i), Vector3(i.x,i.y,0))
		
func connect_points(nodes : PoolVector2Array):
	for i in nodes.size():
		connect_points.append([]) #For drawing connections
		for b in nodes.size() - 1 - i:
			print(i)
			print(b + 1 + i)
			if space_state:
				var result = space_state.intersect_ray(nodes[i],nodes[b + 1 + i])
				if result.empty():
					print("Yes")
					astar.connect_points(get_point_id(nodes[i]), get_point_id(nodes[b + 1 + i]))
					connect_points[i].append(nodes[b + 1 + i]) #For drawing connections
				else:
					print("No")
			else:
				print("No space state")

	print(connect_points)
	draw_connection = true

func _physics_process(delta):
	space_state = get_world_2d().direct_space_state
	if get_connection:
		connect_points(graph_nodes)
	get_connection = false

func get_point_id(point):
	var x = point.x - boundry.position.x
	var y = point.y - boundry.position.y
	
	return x + y*boundry.size.x
