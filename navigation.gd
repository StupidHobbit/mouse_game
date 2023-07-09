extends Node

class_name Navigation

@export var maze: Maze

var astar: AStar2D = AStar2D.new()
var is_initialised: bool = false

signal initialised


func _ready():
	call_deferred("init_walls")
	
func init_walls():
	if not maze.is_node_ready():
		await maze.ready
		
	var size = maze.size
	for i in range(-1, size.x + 1):
		for j in range(-1, size.y + 1):
			var pos = Vector2i(i, j)
			astar.add_point(cell_to_id(pos), pos)
			
	for i in range(0, size.x):
		for j in range(0, size.y):
			var pos = Vector2i(i, j)
			astar.connect_points(cell_to_id(pos), cell_to_id(Vector2i(i-1, j)))
			astar.connect_points(cell_to_id(pos), cell_to_id(Vector2i(i+1, j)))
			astar.connect_points(cell_to_id(pos), cell_to_id(Vector2i(i, j+1)))
			astar.connect_points(cell_to_id(pos), cell_to_id(Vector2i(i, j-1)))
	
	for w in maze.get_walls():
		add_obstacle(w)
	is_initialised = true
	initialised.emit()

		
func find_path(from: Vector2i, to: Vector2i) -> PackedVector2Array:
	return astar.get_point_path(cell_to_id(from), cell_to_id(to))

func add_obstacle(cell: Vector2i):
	var id = cell_to_id(cell)
	if astar.has_point(id):
		astar.set_point_disabled(id, true)

func remove_obstacle(cell: Vector2i):
	astar.set_point_disabled(cell_to_id(cell), false)

func is_wall(cell: Vector2i) -> bool:
	var id = cell_to_id(cell)
	return !astar.has_point(id) or astar.is_point_disabled(id)
	
func cell_to_id(cell: Vector2i) -> int:
	return (cell.x + 10) << 8 | (cell.y + 10)	
	
func cell_from_id(id: int) -> Vector2i:
	return Vector2i(id >> 8, id & 127)

func _process(delta):
	pass
