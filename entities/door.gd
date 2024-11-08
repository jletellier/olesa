extends "res://entities/entity.gd"


func process_logic() -> void:
	var neighbors := map.get_moore_neighbors(pos)
	
	var found_tool := false
	for neighbor in neighbors:
		if neighbor is EntityDB.Jo:
			if neighbor.has_tool:
				found_tool = true
				break
	
	if found_tool:
		print("open door")
