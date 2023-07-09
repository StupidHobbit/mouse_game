extends Node3D

@onready var tbd_system = $tbd_system	
@onready var maze = $maze
@onready var navigation: Navigation = $navigation
@onready var mouse_counter = $mouse_counter

var mice: Mouse
var snake: Snake
var mice_scene = preload("res://mice.tscn")

func _ready():
	call_deferred("init")

func init():
	if not navigation.is_initialised:
		await navigation.initialised
	
	snake = preload("res://snake/snake.tscn").instantiate()
	snake.navigation = navigation
	add_child(snake)
	spawn_mouse()
	snake.mouse = mice
	tbd_system.add_object(snake)
	
	WinMenu.mouse_counter = mouse_counter
	
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
		mice_cell = Vector2i(randi_range(0, maze_size.x - 1), randi_range(0, maze_size.y - 1))
		if not navigation.is_wall(mice_cell) and snake.head_cell() != mice_cell:
			break
	return mice_cell
	
func on_mouse_killed():
	mice.set_cell(find_new_mice_cell())
	mouse_counter.add_mouse()

func _process(delta):
	pass
