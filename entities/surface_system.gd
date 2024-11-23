extends "res://entities/entity_system.gd"


const MoveableSystem := preload("res://entities/moveable_system.gd")
const EntitySuccess := preload("res://ui/hints/entity_success.gd")

@export var object_texture: Texture2D

var has_object := false

var _moveable_system: MoveableSystem
var _hint_success: EntitySuccess
var _audio_finish: AudioStreamPlayer
var _sprite: Sprite2D


func start() -> void:
	_moveable_system = entity.get_system("MoveableSystem")
	_hint_success = entity.get_node("HintSuccess")
	_audio_finish = entity.get_node("AudioFinish")
	_sprite = entity.get_node("Sprite2D")
	
	_moveable_system.collided_with.connect(_on_collided_with)


func destroy() -> void:
	_moveable_system.collided_with.disconnect(_on_collided_with)


func _on_collided_with(other_entity: Entity) -> void:
	if other_entity.type == "object" and !has_object:
		entity.map.remove_entity(other_entity)
		has_object = true
		_sprite.texture = object_texture
		_hint_success.animate()
		_audio_finish.play()
