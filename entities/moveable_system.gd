extends "res://entities/entity_system.gd"


var _audio_movement: AudioStreamPlayer


func start() -> void:
	_audio_movement = entity.get_node("AudioMovement")


func action(dir: Vector2i) -> void:
	entity.map.cascade_push(entity.pos, dir)
	_audio_movement.play()
