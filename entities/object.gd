extends "res://entities/entity.gd"


const Lawa := preload("res://entities/lawa.gd")
const Jo := preload("res://entities/jo.gd")
const WallCracked := preload("res://entities/wall_cracked.gd")
const EntityObject := preload("res://entities/object.gd")


func process_action(dir: Vector2i) -> void:
	move_requested.emit(dir)


func collide_with(target_entity: Entity) -> void:
	if target_entity is WallCracked:
		free_requested.emit()


func can_push(target_entity: Entity) -> bool:
	return (target_entity is Lawa or \
			target_entity is Jo or \
			target_entity is EntityObject or \
			target_entity is WallCracked)
