extends RefCounted

class_name Queue

var _inner: Array
var max_size: int = 100
var i: int = 0
var j: int = -1

func _init(max_size: int = 100):
	_inner = []
	for i in range(max_size):
		_inner.append(null)
	
func add_front(v):
	j += 1
	if j == max_size:
		j = 0
	_inner[j] = v
		
func add_back(v):
	i -= 1
	if i == -1:
		i = len(_inner) - 1
	_inner[i] = v

func get_second_front():
	return _inner[j-1]
	
func get_front():
	return _inner[j]
	
func get_back():
	return _inner[i]

func pop_back():
	var x = _inner[i]
	i += 1
	if i == len(_inner):
		i = 0
	return x
