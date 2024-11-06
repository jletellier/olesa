extends Node2D


@warning_ignore("unused_signal")
signal move_requested(dir: Vector2i)

@warning_ignore("unused_signal")
signal free_requested()

const Entity := preload("res://entities/entity.gd")

@export var texture: Texture2D
@export var selectable := false

var pos := Vector2i.ZERO

@onready var _sprite := $"Sprite2D" as Sprite2D


func _ready() -> void:
	_sprite.texture = texture


@warning_ignore("unused_parameter")
func process_action(dir: Vector2i) -> void:
	pass


@warning_ignore("unused_parameter")
func collide_with(target_entity: Entity) -> void:
	pass


@warning_ignore("unused_parameter")
func can_push(target_entity: Entity) -> bool:
	return false
