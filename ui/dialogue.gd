extends CanvasLayer


@export var text := "":
	set = _set_text

@export var text_speed := 50

var _text_length := 0

@onready var _label := $"CenterContainer/MarginContainer/MarginContainer/Label" as Label


func _ready() -> void:
	_set_text(text)


func _process(delta: float) -> void:
	_label.visible_ratio += delta * text_speed / _text_length
	if _label.visible_ratio >= 1:
		_label.visible_ratio = 1
		set_process(false)


func _set_text(value: String) -> void:
	text = value
	
	if _label == null:
		return
	
	_label.text = text.c_unescape()
	_text_length = _label.text.length()
	if _text_length > 0:
		visible = true
		_label.visible_ratio = 0
		set_process(true)
	else:
		visible = false
		set_process(false)
