extends "res://entities/entity.gd"


@export var texture_door: Texture2D
@export var texture_hint: Texture2D

var is_open := false:
	set = _set_is_open


func _ready() -> void:
	_set_is_open(is_open)


func process_logic() -> void:
	if is_open and map._entity_map.get(Vector3i(pos.x, pos.y, 0)) != null:
		return
	
	var neighbors := map.get_moore_neighbors(pos)
	var found_tool := false
	for neighbor in neighbors:
		if neighbor is EntityDB.Jo:
			if neighbor.has_tool:
				found_tool = true
				break
	
	is_open = found_tool


func _set_is_open(value: bool) -> void:
	is_open = value
	layer = 1 if is_open else 0
	texture = texture_hint if is_open else texture_door
