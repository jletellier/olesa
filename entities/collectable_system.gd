extends "res://entities/entity_system.gd"


const CollectableSystem := preload("res://entities/collectable_system.gd")
const EntityPossess := preload("res://ui/hints/entity_possess.gd")

var has_tool := false
var has_item := false

var _hint_possess: EntityPossess
var _audio_action: AudioStreamPlayer


func start() -> void:
	_hint_possess = entity.get_node("HintPossess")
	_audio_action = entity.get_node("AudioAction")


func action(dir: Vector2i) -> void:
	var target_pos := entity.pos + dir
	var neighbor: Entity = entity.map._entity_map.get(Vector3i(target_pos.x, target_pos.y, 0))
	var neighbor_system := neighbor.get_system("CollectableSystem")
	if neighbor_system != null:
		if neighbor_system.has_tool != has_tool:
			neighbor.has_tool = !neighbor.has_tool
			has_tool = !has_tool
			_hint_possess.active = has_tool
			_audio_action.play()
	
		if neighbor.has_item and !has_item:
			neighbor.has_item = false
			has_item = true
			_hint_possess.active = true
			_audio_action.play()
