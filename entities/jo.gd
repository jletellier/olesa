extends "res://entities/entity.gd"


var has_tool := false


func process_action(dir: Vector2i) -> void:
	var neighbor: Entity = map._entity_map.get(pos + dir)
	if neighbor is EntityDB.EntityContainer:
		if neighbor.has_tool != has_tool:
			neighbor.has_tool = !neighbor.has_tool
			has_tool = !has_tool
