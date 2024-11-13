extends Node2D


const Map := preload("res://maps/map.gd")
const Entity := preload("res://entities/entity.gd")
const EntityDB := preload("res://entities/entity_db.gd")
const EntitySelect := preload("res://ui/hints/entity_select.gd")

signal history_transaction(entity: Entity, attribute: String, value: Variant)

@export var texture: Texture2D:
	set = _set_texture
		
@export var selectable := false
@export var process := false

var pos := Vector2i.ZERO:
	set = _set_pos

var layer := 0:
	set = _set_layer

var selected := false:
	set = _set_selected

var map: Map

@onready var _sprite := $"Sprite2D" as Sprite2D
@onready var _hint_select := $"HintSelect" as EntitySelect


func process_logic() -> void:
	pass


@warning_ignore("unused_parameter")
func process_action(dir: Vector2i) -> void:
	pass


@warning_ignore("unused_parameter")
func collide_with(target_entity: Entity) -> void:
	pass


@warning_ignore("unused_parameter")
func can_push(target_entity: Entity) -> bool:
	return false


func _set_texture(value: Texture2D) -> void:
	texture = value
	if _sprite != null:
		_sprite.texture = texture


func _set_pos(value: Vector2i) -> void:
	var old_pos := pos
	pos = value
	
	if map != null:
		map.move_entity(self, old_pos)
		
		if pos != old_pos:
			history_transaction.emit(self, "pos", old_pos)


func _set_layer(value: int) -> void:
	var old_layer := layer
	layer = value
	
	if map != null:
		map._entity_map.erase(Vector3i(pos.x, pos.y, old_layer))
		map._entity_map[Vector3i(pos.x, pos.y, layer)] = self


func _set_selected(value: bool) -> void:
	selected = value
	
	if _hint_select != null:
		_hint_select.visible = selected
		if selected:
			_hint_select.animate()
