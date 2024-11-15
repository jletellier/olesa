extends "res://entities/entity.gd"


const EntityTarget := preload("res://ui/hints/entity_target.gd")

var current_target: Entity:
	set = _set_current_target

@onready var _hint_target := $"HintTarget" as EntityTarget


func process_action(dir: Vector2i) -> void:
	var target_pos := pos + dir
	var neighbor: Entity = map._entity_map.get(Vector3i(target_pos.x, target_pos.y, 0))
	current_target = neighbor


func _update_hints() -> void:
	_hint_select.visible = selected
	_hint_target.visible = (selected and current_target != null)


func _set_current_target(value: Entity) -> void:
	if current_target is EntityDB.Mountain and current_target != value:
		current_target.has_worker = false
	
	current_target = value
	
	if current_target is EntityDB.Mountain:
		current_target.has_worker = true
	
	if _hint_target != null:
		_update_hints()
		if current_target != null:
			_hint_target.global_position = current_target.global_position
			_hint_target.animate()


func _set_selected(value: bool) -> void:
	selected = value
	
	if _hint_select != null:
		_update_hints()
		if selected:
			_hint_select.animate()
			_hint_target.animate()
