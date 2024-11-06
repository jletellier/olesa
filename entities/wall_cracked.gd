extends "res://entities/entity.gd"


const EntityObject := preload("res://entities/object.gd")


func collide_with(target_entity: Entity) -> void:
	if target_entity is EntityObject:
		free_requested.emit()
