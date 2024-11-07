extends Node2D


const Map := preload("res://maps/map.gd")
const Entity := preload("res://entities/entity.gd")
const EntityDB := preload("res://entities/entity_db.gd")

@export var texture: Texture2D
@export var selectable := false
@export var process := false

var pos := Vector2i.ZERO
var map: Map

@onready var _sprite := $"Sprite2D" as Sprite2D


func _ready() -> void:
	_sprite.texture = texture


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
