extends Node2D

const MOVE_SPEED = 300
var path := PoolVector2Array() setget set_path

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_path(new_path):
	if not new_path:
		pass

	path = new_path
	
func _process(delta):
	if path and path.size() > 1:
		var move_distance = MOVE_SPEED * delta
		var section_distance = position.distance_to(path[1])
		if section_distance > move_distance:
			position += to_local(path[1]).normalized() * move_distance
		else:
			path.remove(0)
