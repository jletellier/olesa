extends "res://entities/entity_system.gd"


const MoveableSystem := preload("res://entities/moveable_system.gd")

var _moveable_system: MoveableSystem
var _audio_destroy: AudioStreamPlayer


func start() -> void:
	_moveable_system = entity.get_system("MoveableSystem")
	_audio_destroy = entity.get_node("AudioDestroy")
	
	_moveable_system.collided_with.connect(_on_collided_with)


func destroy() -> void:
	_moveable_system.collided_with.disconnect(_on_collided_with)


func _on_collided_with(other_entity: Entity) -> void:
	if other_entity.type == "object":
		# Move audio player, otherwise it gets freed as well
		_audio_destroy.reparent(entity.map.get_parent())
		_audio_destroy.play()
		
		entity.map.remove_entity(other_entity)
		entity.map.remove_entity(entity)
