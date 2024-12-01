extends CanvasLayer


@export var text := "":
	set = _set_text

@export var text_speed := 50

@export var placement_top := true:
	set = _set_placement_top

var _text_length := 0
var _last_audio_delta := 0.0

@onready var _center_container := $"CenterContainer" as CenterContainer
@onready var _label := $"CenterContainer/MarginContainer/MarginContainer/Label" as Label
@onready var _typing_audio := $"TypingAudio" as AudioStreamPlayer


func _ready() -> void:
	_set_text(text)


func _process(delta: float) -> void:
	_label.visible_ratio += delta * text_speed / _text_length
	
	if _label.visible_ratio >= 1:
		_label.visible_ratio = 1
		set_process(false)
	
	_last_audio_delta += delta
	if _last_audio_delta > (4.0 / text_speed):
		_last_audio_delta = 0.0
		_typing_audio.play()


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


func _set_placement_top(value: bool) -> void:
	placement_top = value
	
	if _center_container == null:
		return
	
	_center_container.set_anchors_preset(
			Control.PRESET_CENTER_TOP if placement_top else Control.PRESET_CENTER_BOTTOM, true)
	
	# FIXME: This is weird? Figure out why!
	if placement_top:
		_center_container.position.y = 0
	else:
		var viewport_size := get_tree().root.size / get_tree().root.content_scale_factor
		_center_container.position.y = floor(viewport_size.y - _center_container.size.y)
