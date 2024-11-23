extends "res://entities/entity_system.gd"


const MoveableSystem := preload("res://entities/moveable_system.gd")

var _moveable_system: MoveableSystem
var _other_portal: Entity


func start() -> void:
	_moveable_system = entity.get_system("MoveableSystem")
	_moveable_system.collided_with.connect(_on_collided_with)
	
	var entities := entity.map.get_entities_with_system("PortalSystem")
	for other_entity in entities:
		if other_entity != entity:
			_other_portal = other_entity
			break


func destroy() -> void:
	_moveable_system.collided_with.disconnect(_on_collided_with)


func _on_collided_with(other_entity: Entity) -> void:
	if _other_portal == null:
		return
	
	var other_moveable_system: MoveableSystem = other_entity.get_system("MoveableSystem")
	var dir := other_moveable_system.target_pos - other_entity.pos
	var target_pos := _other_portal.pos + dir
	
	# Cascade push entity on the other side of the portal
	var cascade_entity := entity.map.get_entity(target_pos)
	if cascade_entity != null:
		var cascade_moveable_system: MoveableSystem = cascade_entity.get_system("MoveableSystem")
		if cascade_moveable_system != null:
			other_moveable_system.collided_with.emit(cascade_entity)
			cascade_moveable_system.collided_with.emit(other_entity)
			
			if !cascade_entity.is_queued_for_deletion() and \
					!other_entity.is_queued_for_deletion():
				cascade_moveable_system.cascade_push(dir)
	
	# Fetch target cell/entity on the other side of the portal
	var target_cell := entity.map.get_cell(target_pos)
	var target_entity := entity.map.get_entity(target_pos)
	
	# Action: Target is empty
	if target_cell == entity.map.TILE_EMPTY and target_entity == null:
		other_moveable_system.target_pos = target_pos
