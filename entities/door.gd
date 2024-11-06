extends "res://entities/entity.gd"


func process_logic() -> void:
	var neighbors = _get_moore_neighbors.call(pos)
	print(neighbors)
