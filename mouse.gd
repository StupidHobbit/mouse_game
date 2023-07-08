@tool

extends Node3D

enum States {IDLE, TWEEN}

@export var tween_time: float = 1
@export var grid_size: float = 2
@export var navigation: Navigation
@export var cell: Vector2i:
	get:
		return cell
	set(value):
		cell = value
		if Engine.is_editor_hint():
			update_position()

@onready var animation_player = $AnimationPlayer


var state := States.IDLE

func _ready():
	if Engine.is_editor_hint():
		return
	update_position()
	animation_player.animation_finished.connect(on_anim_end)

func update_position():
	position = cell_to_position(cell)

func cell_to_position(cell: Vector2i) -> Vector3:
	return Vector3(cell.x + 0.5, 1, cell.y + 0.5) * grid_size

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
				rotation = Vector3(rotation.x, atan2(input.y, -input.x), rotation.z)
				cell = new_cell
				state = States.TWEEN
				animation_player.play("Walk")
				var tween := get_tree().create_tween()
				tween.finished.connect(tween_finished)
				tween.tween_property(self, "position", cell_to_position(new_cell), tween_time)

func tween_finished() -> void:
	state = States.IDLE
	play_idle_animation()
	
func on_anim_end(anim_name: String):
	if anim_name == "Walk":
		return
	play_idle_animation()
	
func play_idle_animation():
	animation_player.play(IDLE_ANIMATIONS.pick_random())

const IDLE_ANIMATIONS = ["Idle", "Idle_stand", "Idle_still"]
