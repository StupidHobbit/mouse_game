extends Node

class_name Navigation

@export var maze: Maze

var walls: Dictionary

func _ready():
	call_deferred("init_walls")
	
func init_walls():
	if not maze.is_node_ready():
		await maze.ready
	for w in maze.get_walls():
		walls[w] = true
		
func is_wall(cell: Vector2i) -> bool:
	return walls.get(cell, false)
	
func _process(delta):
	pass
