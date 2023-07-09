extends Node

var level_scene = preload("res://level.tscn")
var level: Node

@onready var audio_stream_player_2d = $AudioStreamPlayer2D


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
	play_music()
	audio_stream_player_2d.finished.connect(play_music)
	
func play_music():
	audio_stream_player_2d.play(0)
	
	
func load_level():
	level = level_scene.instantiate()
	add_child(level)

func _process(delta):
	pass

func _input(event: InputEvent):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
