extends "res://entities/entity.gd"


const EntityPossess := preload("res://ui/hints/entity_possess.gd")

var has_tool := false
var has_item := false

@onready var _hint_possess := $"HintPossess" as EntityPossess
@onready var _audio_action := $"AudioAction" as AudioStreamPlayer


func process_action(dir: Vector2i) -> void:
	var target_pos := pos + dir
	var neighbor: Entity = map._entity_map.get(Vector3i(target_pos.x, target_pos.y, 0))
	if neighbor is EntityDB.EntityContainer:
		if neighbor.has_tool != has_tool:
			neighbor.has_tool = !neighbor.has_tool
			has_tool = !has_tool
			_hint_possess.active = has_tool
			_audio_action.play()
	elif neighbor is EntityDB.Mountain:
		if neighbor.has_item and !has_item:
			neighbor.has_item = false
			has_item = true
			_hint_possess.active = true
			_audio_action.play()
	elif neighbor is EntityDB.Construction:
		if !neighbor.has_item and has_item:
			neighbor.has_item = true
			has_item = false
			_hint_possess.active = false
			_audio_action.play()
