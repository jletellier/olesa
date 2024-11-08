extends "res://entities/entity.gd"


func process_action(dir: Vector2i) -> void:
	map.move_entity(self, dir)


func collide_with(target_entity: Entity) -> void:
	if target_entity is EntityDB.Lawa:
		map.remove_entity(self)


func can_push(target_entity: Entity) -> bool:
	return (target_entity is EntityDB.Jo or \
			target_entity is EntityDB.EntityObject)
