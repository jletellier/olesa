extends "res://entities/entity_system.gd"


const MoveableSystem := preload("res://entities/moveable_system.gd")

var _audio_movement: AudioStreamPlayer
var _moveable_system: MoveableSystem


func start() -> void:
	_audio_movement = entity.get_node("AudioMovement")
	_moveable_system = entity.get_system("MoveableSystem")
	
	_moveable_system.moved.connect(_on_moved)


func destroy() -> void:
	_moveable_system.moved.disconnect(_on_moved)


func _on_moved() -> void:
	_audio_movement.play()
