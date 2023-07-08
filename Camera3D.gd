extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event: InputEvent):
	if Input.is_action_just_pressed("zoom_in"):
		if size > 3:
			size -= 2
	if Input.is_action_just_pressed("zoom_out"):
		if size < 30:
			size += 2
