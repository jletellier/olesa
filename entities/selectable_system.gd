extends "res://entities/entity_system.gd"


const EntitySelect := preload("res://ui/hints/entity_select.gd")

signal selected_changed()

var selected := false:
	set = _set_selected

var _hint_select: EntitySelect
var _select_button: TouchScreenButton


func start() -> void:
	_hint_select = entity.get_node("HintSelect")
	_select_button = entity.get_node_or_null("SelectButton")
	if _select_button != null:
		_select_button.pressed.connect(_on_select_button_pressed)


func destroy() -> void:
	if _select_button != null:
		_select_button.pressed.disconnect(_on_select_button_pressed)


func _set_selected(value: bool) -> void:
	var changed := (selected != value)
	selected = value
	
	if changed and selected:
		entity.map.set_selected_system(self)
	
	if changed:
		selected_changed.emit()
	
	if _hint_select != null:
		_hint_select.visible = selected
		if selected:
			_hint_select.animate()


func _on_select_button_pressed() -> void:
	selected = true
