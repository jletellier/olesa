extends "res://entities/entity_system.gd"


const MoveableSystem := preload("res://entities/moveable_system.gd")

signal collided_with(other: Entity)
signal moved()

@export var can_initiate := false
@export var can_move := true

var pos := Vector2i.ZERO:
	get: return entity.pos
	set(value):
		var old_value := pos
		entity.pos = value
		if old_value != value:
			emit_history_transaction("pos", old_value)

var target_pos := Vector2i.ZERO


func action(dir: Vector2i) -> void:
	if can_initiate:
		cascade_push(dir)


func cascade_push(dir: Vector2i) -> void:
	if !can_move:
		return
	
	target_pos = entity.pos + dir
	
	var cascade_entity: Entity = entity.map.get_entity(target_pos)
	if cascade_entity != null:
		var cascade_system: MoveableSystem = cascade_entity.get_system("MoveableSystem")
	
		if cascade_system != null:
			collided_with.emit(cascade_entity)
			cascade_system.collided_with.emit(entity)
			
			if !cascade_entity.is_queued_for_deletion():
				cascade_system.cascade_push(dir)
	
	# Fetch target cell/entity again, in case it has been moved/removed
	var target_cell := entity.map.get_cell(target_pos)
	var target_entity: Entity = entity.map.get_entity(target_pos)
	
	# Action: Target is empty
	if target_cell == entity.map.TILE_EMPTY and target_entity == null:
		pos = target_pos
		moved.emit()
