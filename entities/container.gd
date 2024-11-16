extends "res://entities/entity.gd"


@export var texture_tool : Texture2D

var has_tool := false:
	set = _set_has_tool

@onready var _sprite_content := $"SpriteContent" as Sprite2D


func _ready() -> void:
	_set_has_tool(has_tool)


func _set_has_tool(value: bool) -> void:
	has_tool = value
	if _sprite_content != null:
		_sprite_content.visible = has_tool
		_sprite_content.texture = texture_tool
