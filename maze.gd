@tool

extends Node3D

class_name Maze

@export var size: Vector2i = Vector2i(10, 10)

@onready var grid_map = $GridMap

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(size.x):
		for j in range(size.y):
			grid_map.set_cell_item(Vector3i(i, 0, j), 0)
			
	for i in range(-1, size.x + 1):
		grid_map.set_cell_item(Vector3i(i, 1, -1), 0)
		grid_map.set_cell_item(Vector3i(i, 1, size.y), 0)
		
	for j in range(-1, size.y + 1):
		grid_map.set_cell_item(Vector3i(-1, 1, j), 0)
		grid_map.set_cell_item(Vector3i(size.x, 1, j), 0)

func get_walls() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for p in grid_map.get_used_cells():
		if p.y == 1:
			result.append(Vector2i(p.x, p.z))
	return result

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
