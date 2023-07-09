extends PopupPanel

var turned_on: bool = false

signal pressed_exit
signal pressed_play_again

@onready var try_again_button = $VBoxContainer/try_again_button
@onready var exit_button = $VBoxContainer/exit_button
@onready var label_2 = $VBoxContainer/Label2

var mouse_counter: MouseCounter

var pattern: String 

func _ready():
	hide()
	try_again_button.button_up.connect(func():
		pressed_play_again.emit()
		turn_off()
	)
	exit_button.button_up.connect(func():
		pressed_exit.emit()
	)
	pattern = label_2.text

func turn_on():
	show()
	popup_centered()
	label_2.text = pattern % mouse_counter.count
	turned_on = true
	
func turn_off():
	hide()
	turned_on = false

func _process(delta):
	if turned_on:
		show()
