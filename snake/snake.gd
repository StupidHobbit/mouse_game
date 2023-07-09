extends TBDObject

class_name Snake

@export var tween_time: float = 0.5
@export var speed: int = 2

const grid_size: float = 2  
@export var navigation: Navigation
var mouse: Mouse

var angle_part = preload("res://snake/snake_angle.tscn")
var middle_part = preload("res://snake/snake_middle.tscn")
var tail_part = preload("res://snake/snake_tail.tscn")
var head_part = preload("res://snake/snake_head.tscn")

@onready var death_sound_player = $deathSoundPlayer
@onready var idle_sound_player = $idleSoundPlayer
@onready var attack_sound_player = $attackSoundPlayer
@onready var eat_sound_player = $eatSoundPlayer

var head: Node
var tail: Node

var queue: Queue = Queue.new()

enum Direction {UP, LEFT, DOWN, RIGHT, UNKNOWN}

class PartInfo:
	var node: Node3D
	var direction: Direction
	var cell: Vector2i
	
	func _init(node: Node3D, direction: Direction, cell: Vector2i):
		self.node = node
		self.direction = direction
		self.cell = cell
		self.setup_part()
	
	func setup_part():
		self.node.position = cell_to_position(self.cell)
		self.node.rotation = direction_to_rotation[self.direction]

	func cell_to_position(cell: Vector2i) -> Vector3:
		return Vector3(cell.x + 0.5, 1, cell.y + 0.5) * grid_size

func add_part(part: PackedScene, direction: Direction, cell: Vector2i) -> Node:
	var instanced = create_part(part, direction, cell)
	queue.add_front(PartInfo.new(instanced, direction, cell))
	return instanced

func create_part(part: PackedScene, direction: Direction, cell: Vector2i) -> Node3D:
	var instanced = part.instantiate()
	add_child(instanced)
	return instanced

func head_cell() -> Vector2i:
	return queue.get_front().cell

func _ready():
	tail = add_part(tail_part, Direction.RIGHT, Vector2i(0, 0))
	navigation.add_obstacle(Vector2i(0, 0))
	add_part(middle_part, Direction.RIGHT, Vector2i(1, 0))
	navigation.add_obstacle(Vector2i(1, 0))
	head = add_part(head_part, Direction.RIGHT, Vector2i(2, 0))
	
	head.get_node("AnimationPlayer").animation_finished.connect(on_head_animation_finish)
	on_head_animation_finish("")
	tail.get_node("AnimationPlayer").animation_finished.connect(on_tail_animation_finish)
	on_tail_animation_finish("")
	
	attack_sound_player.finished.connect(eat_sound_player.play)
	play_idle_sound()


func play_idle_sound():
	await get_tree().create_timer(randf_range(5, 15)).timeout
	idle_sound_player.play()
	call_deferred("play_idle_sound")

func next_turn():
	var head_info: PartInfo = queue.get_front()
	var path = navigation.find_path(head_info.cell, mouse.cell)
	if len(path) == 0:
		var free_direction = find_free_direction_near()
		if free_direction == Direction.UNKNOWN:
			WinMenu.turn_on()
			return
		move(free_direction)
		return
	
	if len(path) == 1:
		move(find_free_direction_near())
		return
	var next_cell = Vector2i(path[1])
	var direction = offset_to_direction[next_cell - head_info.cell]
	move(direction)
	
func find_free_direction_near() -> Direction:
	var head_cell = head_cell()
	for direction in direction_to_offset:
		if not navigation.is_wall(head_cell + direction_to_offset[direction]):
			return direction
	return Direction.UNKNOWN
	
func _process(delta):
	if has_turn:
		for i in range(speed):
			next_turn()
		make_turn()

func move(direction: Direction):
	var head_info: PartInfo = queue.get_front()
	var new_head_cell = head_info.cell + direction_to_offset[direction]
	if new_head_cell == mouse.cell or head_info.cell == mouse.cell:
		head.get_node("AnimationPlayer").play("Bite_snake")
		attack_sound_player.play()
		mouse.kill()
	else:
		move_tail()

	var neck_info: PartInfo = queue.get_second_front()
	var part_to_add = middle_part if neck_info.direction == direction else angle_part
	var new_part = create_part(part_to_add, head_info.direction, head_info.cell)
	
	navigation.add_obstacle(head_info.cell)
	queue.add_front(PartInfo.new(head_info.node, direction, new_head_cell))
	head_info.node = new_part
	head_info.direction = direction	
	head_info.setup_part()
	if part_to_add == angle_part:
		head_info.node.rotation = convert_directions_to_angle_part_rotation(neck_info.direction, direction)

func move_tail():
	var tail_info: PartInfo = queue.pop_back()
	var new_tail_info: PartInfo = queue.get_back()
	tail_info.node.position = new_tail_info.node.position
	navigation.remove_obstacle(tail_info.cell)
	new_tail_info.node.queue_free()
	new_tail_info.node = tail_info.node
	new_tail_info.setup_part()
	

func convert_directions_to_angle_part_rotation(direction_from: Direction, direction_to: Direction) -> Vector3:
	return directions_to_angle_part_rotation.get([direction_from, direction_to])

func on_head_animation_finish(anim_name: String):
	head.get_node("AnimationPlayer").play(head_idle_animations.pick_random())

func on_tail_animation_finish(anim_name: String):
	tail.get_node("AnimationPlayer").play(tail_idle_animations.pick_random())

const head_idle_animations = ["Idle_snake", "Idle_snake_yawn"]
const tail_idle_animations = ["Idle_tail", "Idle_tail_strike"]

const direction_to_offset = {
	Direction.UP: Vector2i(0, -1),
	Direction.LEFT: Vector2i(-1, 0),
	Direction.DOWN: Vector2i(0, 1),
	Direction.RIGHT: Vector2i(1, 0),
}

const offset_to_direction = {
	Vector2i(0, -1): Direction.UP,
	Vector2i(-1, 0): Direction.LEFT,
	Vector2i(0, 1): Direction.DOWN,
	Vector2i(1, 0): Direction.RIGHT,
}

const direction_to_rotation = {
	Direction.UP: Vector3(0, PI * 3 / 2, 0),
	Direction.LEFT: Vector3(0, PI * 4 / 2, 0),
	Direction.DOWN: Vector3(0, PI * 1 / 2, 0),
	Direction.RIGHT: Vector3(0, PI * 2 / 2, 0),
}

const directions_to_angle_part_rotation = {
	[Direction.UP, Direction.LEFT]: Vector3(0, PI * 2 / 2, 0),
	[Direction.DOWN, Direction.LEFT]: Vector3(0, PI * 1 / 2, 0),
	[Direction.DOWN, Direction.RIGHT]: Vector3(0, PI * 4 / 2, 0),
	[Direction.UP, Direction.RIGHT]: Vector3(0, PI * 3 / 2, 0),
	[Direction.LEFT, Direction.UP]: Vector3(0, PI * 4 / 2, 0),
	[Direction.LEFT, Direction.DOWN]: Vector3(0, PI * 3 / 2, 0),
	[Direction.RIGHT, Direction.DOWN]: Vector3(0, PI * 2 / 2, 0),
	[Direction.RIGHT, Direction.UP]: Vector3(0, PI * 1 / 2, 0),
}
