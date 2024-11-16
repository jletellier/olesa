extends "res://entities/entity.gd"


var has_tool := false

@onready var _animated_carrying := $"AnimatedCarrying" as AnimatedSprite2D


func process_action(dir: Vector2i) -> void:
	var target_pos := pos + dir
	var neighbor: Entity = map._entity_map.get(Vector3i(target_pos.x, target_pos.y, 0))
	if neighbor is EntityDB.EntityContainer:
		if neighbor.has_tool != has_tool:
			neighbor.has_tool = !neighbor.has_tool
			has_tool = !has_tool
			
			_animated_carrying.frame = 0
			if has_tool:
				_animated_carrying.play()
			else:
				_animated_carrying.play_backwards()
