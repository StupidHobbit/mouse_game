@tool

extends CharacterBody3D

enum States {IDLE, TWEEN}

@export var tween_time := 0.3
@export var grid_size: float = 1
@export var navigation: Navigation
@export var cell: Vector2i:
	get:
		return cell
	set(value):
		cell = value
		if Engine.is_editor_hint():
			update_position()
	

var state := States.IDLE

func _ready():
	update_position()

func update_position():
	position = cell_to_position(cell)

func cell_to_position(cell: Vector2i) -> Vector3:
	return Vector3(cell.x + 0.5, 1 + 0.1, cell.y + 0.5) * grid_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		return
	match state:
		States.IDLE:
			var input := Input.get_vector("left", "right", "up", "down")
			if input.x != 0.0 and input.y != 0.0:
				input.y = 0.0
			var offset = Vector3(input.x, 0, input.y)
			if input:
				var new_cell = cell + Vector2i(input.x, input.y)
				if navigation.is_wall(new_cell):
					return
				rotation = Vector3(rotation.x, atan2(input.y, input.x), rotation.z)
				cell = new_cell
				state = States.TWEEN
				var tween := get_tree().create_tween()
				tween.finished.connect(tween_finished)
				tween.tween_property(self, "position", cell_to_position(new_cell), tween_time)

func tween_finished() -> void:
	state = States.IDLE
