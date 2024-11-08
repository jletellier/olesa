extends "res://entities/entity.gd"


func collide_with(target_entity: Entity) -> void:
	if target_entity is EntityDB.WallCracked:
		map.remove_entity(self)
	elif target_entity is EntityDB.Surface:
		if !target_entity.has_object:
			map.remove_entity(self)


func can_push(target_entity: Entity) -> bool:
	if target_entity is EntityDB.Surface:
		if !target_entity.has_object:
			return true
	
	return (target_entity is EntityDB.Lawa or \
			target_entity is EntityDB.Jo or \
			target_entity is EntityDB.EntityObject or \
			target_entity is EntityDB.WallCracked)
