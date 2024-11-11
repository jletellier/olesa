extends "res://entities/entity.gd"


@export var texture_empty : Texture2D
@export var texture_tool : Texture2D

var has_tool := false:
	set = _set_has_tool


func _ready() -> void:
	_set_has_tool(has_tool)


func _set_has_tool(value: bool) -> void:
	has_tool = value
	texture = texture_tool if has_tool else texture_empty
