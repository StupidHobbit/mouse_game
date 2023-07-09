extends Node

@export var objects: Array[TBDObject]

var current_object_id: int = 0 

func add_object(o: TBDObject):
	objects.append(o)
	o.turn_made.connect(func(): 
		current_object_id += 1
		o.has_turn = false
		if current_object_id == len(objects):
			current_object_id = 0
		objects[current_object_id].has_turn = true
	)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_tbd():
	objects[0].has_turn = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
