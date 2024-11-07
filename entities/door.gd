extends "res://entities/entity.gd"


func process_logic() -> void:
	var neighbors = map.get_moore_neighbors(pos)
	print(neighbors)
