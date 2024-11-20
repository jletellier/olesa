extends "res://entities/entity_system.gd"


const EntitySelect := preload("res://ui/hints/entity_select.gd")

var selected := false:
	set = _set_selected

var _hint_select: EntitySelect


func start() -> void:
	_hint_select = entity.get_node("HintSelect")


func _set_selected(value: bool) -> void:
	selected = value
	
	if _hint_select != null:
		_hint_select.visible = selected
		if selected:
			_hint_select.animate()
