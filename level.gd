extends Node3D

@onready var tbd_system = $tbd_system	
@onready var maze = $maze
@onready var navigation: Navigation = $navigation

var mice: Mouse
var snake: Snake
var mice_scene = preload("res://mice.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_mouse()
	snake = preload("res://snake/snake.tscn").instantiate()
	snake.navigation = navigation
	snake.mouse = mice
	add_child(snake)
	tbd_system.add_object(snake)
	
	tbd_system.init_tbd()

func spawn_mouse():
	mice = mice_scene.instantiate()
	add_child(mice)
	mice.navigation = navigation
	mice.set_cell(find_new_mice_cell())
	tbd_system.add_object(mice)
	mice.killed.connect(on_mouse_killed)

func find_new_mice_cell() -> Vector2i:
	var maze_size = maze.size
	var mice_cell = Vector2i()
	for i in range(500):
		mice_cell = Vector2i(randi_range(3, maze_size.x - 3), randi_range(3, maze_size.y - 3))
		if not navigation.is_wall(mice_cell) and snake.head_cell() != mice_cell:
			break
	return mice_cell
	

func on_mouse_killed():
	mice.set_cell(find_new_mice_cell())

func _process(delta):
	pass
