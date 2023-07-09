extends Node

var level_scene = preload("res://level.tscn")
var level: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	WinMenu.pressed_exit.connect(func():
		get_tree().quit()
	)
	WinMenu.pressed_play_again.connect(func():
		level.queue_free()
		load_level()
	)
	Tutorial.tutor()
	load_level()
	
func load_level():
	level = level_scene.instantiate()
	add_child(level)

func _process(delta):
	pass
