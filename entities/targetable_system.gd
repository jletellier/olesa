extends "res://entities/entity_system.gd"


const EntityTarget := preload("res://ui/hints/entity_target.gd")

var target_entity: Entity:
	set = _set_target_entity

var _hint_target: EntityTarget
var _audio_target_success: AudioStreamPlayer
var _audio_target_failure: AudioStreamPlayer


func start() -> void:
	_hint_target = entity.get_node("HintTarget")
	_audio_target_success = entity.get_node("AudioTargetSuccess")
	_audio_target_failure = entity.get_node("AudioTargetFailure")


func action(dir: Vector2i) -> void:
	var target_pos := entity.pos + dir
	
	var neighbor: Entity = entity.map.get_entity(target_pos, 0)
	target_entity = neighbor
	
	if target_entity != null:
		_audio_target_success.play()
	else:
		_audio_target_failure.play()


func _set_target_entity(value: Entity) -> void:
	target_entity = value
	
	if _hint_target != null and target_entity != null:
		_hint_target.visible = true
		_hint_target.global_position = target_entity.global_position
		_hint_target.animate()
