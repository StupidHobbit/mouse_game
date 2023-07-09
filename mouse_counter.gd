extends Control

@onready var label = $HSplitContainer/Label


var count: int = 0:
	get:
		return count
	set(value):
		count = value
		label.text = "%d" % count

func add_mouse():
	count += 1
