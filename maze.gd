@tool

extends Node3D

class_name Maze

@export var size: Vector2i = Vector2i(10, 10)
@export var decoration_chance: float = 0.2

@onready var grid_map = $GridMap

# Called when the node enters the scene tree for the first time.
func _ready():
	var turn_right = grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), PI / 2))
	var turn_up = grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), PI))
	var turn_left = grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), 3 * PI / 2))
	var turn_down = grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), 2 * PI))
	
	for i in range(-20, size.x + 20):
		for j in range(-20, size.y + 20):
			grid_map.set_cell_item(Vector3i(i, 0, j), grass_light if (i + j) % 2 else grass_dark)
			
			if i < -1 or i > size.x or j < -1 or j > size.y:
				if randf() < decoration_chance:
					grid_map.set_cell_item(Vector3i(i, 1, j), decorations.pick_random())
					
			
	for i in range(size.x):
		grid_map.set_cell_item(Vector3i(i, 1, -1), fence_straight)
		grid_map.set_cell_item(Vector3i(i, 1, size.y), fence_straight)
		
	for j in range(size.y):
		grid_map.set_cell_item(Vector3i(-1, 1, j), fence_straight, turn_left)
		grid_map.set_cell_item(Vector3i(size.x, 1, j), fence_straight, turn_left)
		
	grid_map.set_cell_item(Vector3i(-1, 1, -1), fence_angle, turn_left)
	grid_map.set_cell_item(Vector3i(-1, 1, size.y), fence_angle, turn_down)
	grid_map.set_cell_item(Vector3i(size.x, 1, -1), fence_angle, turn_up)
	grid_map.set_cell_item(Vector3i(size.x, 1, size.y), fence_angle, turn_right)
	

func get_walls() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for p in grid_map.get_used_cells():
		if p.y == 1:
			result.append(Vector2i(p.x, p.z))
	return result

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

const fence_straight = 2
const fence_angle = 3
const grass_light = 0
const grass_dark = 1

const decorations = [4, 5, 6, 8, 9]
