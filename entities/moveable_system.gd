extends "res://entities/entity_system.gd"


const EntitySelect := preload("res://ui/hints/entity_select.gd")
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

var is_moving := false:
	set = _set_is_moving

var _sprite: Sprite2D
var _animation_player: AnimationPlayer
var _hint_select: EntitySelect


func start() -> void:
	_animation_player = entity.get_node_or_null("AnimationPlayer")
	_sprite = entity.get_node("Sprite2D")
	_hint_select = entity.get_node_or_null("HintSelect")


func step_process(delta: float, duration: float) -> void:
	if is_moving:
		var dir := Vector2(target_pos - pos)
		_sprite.position += dir * (delta / duration * 16)
		
		if _hint_select != null:
			_hint_select.position = _sprite.position


func tick() -> void:
	if is_moving:
		is_moving = false
		_sprite.position = Vector2.ZERO
		if _hint_select != null:
			_hint_select.position = _sprite.position
		
		pos = target_pos
		moved.emit()


func action(dir: Vector2i) -> bool:
	if can_initiate:
		cascade_push(dir)
		return is_moving
	return false


func cascade_push(dir: Vector2i) -> void:
	if !can_move:
		return
	
	target_pos = entity.pos + dir
	is_moving = true
	
	var cascade_entity: Entity = entity.map.get_entity(target_pos)
	if cascade_entity != null:
		var cascade_system: MoveableSystem = cascade_entity.get_system("MoveableSystem")
		if cascade_system != null:
			collided_with.emit(cascade_entity)
			cascade_system.collided_with.emit(entity)
			
			if !cascade_entity.is_queued_for_deletion():
				cascade_system.cascade_push(dir)
	
	var target_entity: Entity = entity.map.get_entity(target_pos)
	if target_entity != null:
		var target_system: MoveableSystem = target_entity.get_system("MoveableSystem")
		if target_system != null:
			if !target_entity.is_queued_for_deletion() and !target_system.is_moving:
				is_moving = false
				return
		
	
	var target_cell := entity.map.get_cell(target_pos)
	if target_cell != entity.map.TILE_EMPTY:
		is_moving = false
		return


func _set_is_moving(value: bool) -> void:
	is_moving = value
	
	if _animation_player != null:
		if is_moving:
			var anim_name := &"idle"
			var dir := target_pos - pos
			match(dir):
				Vector2i.RIGHT: anim_name = &"right"
				Vector2i.DOWN: anim_name = &"down"
				Vector2i.LEFT: anim_name = &"left"
				Vector2i.UP: anim_name = &"up"
		
			_animation_player.stop()
			_animation_player.play(anim_name)
