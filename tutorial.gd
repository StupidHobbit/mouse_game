extends PopupPanel

@onready var button = $VBoxContainer/Button

func _ready():
	#hide()
	button.button_up.connect(hide)
	
func tutor():
	show()
	popup_centered()

func _process(delta):
	pass
