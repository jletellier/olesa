@tool
extends Node2D


signal move_requested(dir: Vector2i)
signal free_requested()

const Entity := preload("res://entities/entity.gd")

@export var texture: Texture2D
@export var type := &""
@export var selectable := false

var pos := Vector2i.ZERO

@onready var _sprite := $"Sprite2D" as Sprite2D


func _ready() -> void:
	_sprite.texture = texture


func process_action(dir: Vector2i) -> void:
	match type:
		"lawa":
			move_requested.emit(dir)
		"jo":
			pass
			#var target_cell := get_cell(target_pos)
			#if target_cell == TILE_CONTAINER_TOOL:
				#set_cell(target_pos, TILE_CONTAINER)
			#elif target_cell == TILE_CONTAINER:
				#set_cell(target_pos, TILE_CONTAINER_TOOL)


func collide_with(target_entity: Entity) -> void:
	if type == "lawa" and target_entity.type == "lawa":
		free_requested.emit()
		return
	
	if (type == "object" and target_entity.type == "wall_cracked") or \
			(type == "wall_cracked" and target_entity.type == "object"):
		free_requested.emit()
		return


func can_push(target_entity: Entity) -> bool:
	if type == "lawa":
		return (target_entity.type in ["jo", "object"])
	
	if type == "object":
		return (target_entity.type in ["lawa", "jo", "object", "wall_cracked"])
	
	return false
