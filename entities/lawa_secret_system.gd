extends "res://entities/entity_system.gd"


const MoveableSystem := preload("res://entities/moveable_system.gd")

var _moveable_system: MoveableSystem


func start() -> void:
	_moveable_system = entity.get_system("MoveableSystem")
	
	_moveable_system.collided_with.connect(_on_collided_with)


func destroy() -> void:
	_moveable_system.collided_with.disconnect(_on_collided_with)


func _on_collided_with(other: Entity) -> void:
	if other.type == "lawa":
		entity.map.remove_entity(entity)
	elif other.type == "sitelen_lawa":
		entity.map.remove_entity(entity)
		entity.map.remove_entity(other)
