extends "res://entities/entity.gd"


func collide_with(target_entity: Entity) -> void:
	if target_entity is EntityDB.EntityObject:
		free_requested.emit()
