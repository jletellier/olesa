@tool
extends Node2D


@export var texture: Texture2D
@export var type := &""

var pos := Vector2i.ZERO

@onready var _sprite := $"Sprite2D" as Sprite2D


func _ready() -> void:
	_sprite.texture = texture
