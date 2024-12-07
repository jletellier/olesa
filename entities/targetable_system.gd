extends "res://entities/entity_system.gd"


const EntityTarget := preload("res://ui/hints/entity_target.gd")
const SelectableSystem := preload("res://entities/selectable_system.gd")
const MineableSystem := preload("res://entities/mineable_system.gd")
const ConstructibleSystem := preload("res://entities/constructible_system.gd")
const SitelenSystem := preload("res://entities/sitelen_system.gd")

var target_entity: Entity:
	set = _set_target_entity

var _hint_target: EntityTarget
var _audio_target_success: AudioStreamPlayer
var _audio_target_failure: AudioStreamPlayer
var _selectable_system: SelectableSystem


func start() -> void:
	_hint_target = entity.get_node("HintTarget")
	_audio_target_success = entity.get_node("AudioTargetSuccess")
	_audio_target_failure = entity.get_node("AudioTargetFailure")
	_selectable_system = entity.get_system("SelectableSystem")
	
	_selectable_system.selected_changed.connect(_on_selected_changed)


func destroy() -> void:
	_selectable_system.selected_changed.disconnect(_on_selected_changed)


func action(dir: Vector2i) -> bool:
	var target_pos := entity.pos + dir
	
	var neighbor: Entity = entity.map.get_entity(target_pos, 0)
	target_entity = neighbor
	
	if target_entity != null:
		_audio_target_success.play()
	else:
		_audio_target_failure.play()
	
	return false


func _update_hints() -> void:
	if _hint_target != null:
		_hint_target.visible = (target_entity != null and _selectable_system.selected)
		if target_entity != null:
			_hint_target.global_position = target_entity.global_position
			_hint_target.animate()


func _set_target_entity(value: Entity) -> void:
	if target_entity != null:
		var mineable_system: MineableSystem = target_entity.get_system("MineableSystem")
		if mineable_system != null:
			mineable_system.worker = null
		
		var constructible_system: ConstructibleSystem = \
				target_entity.get_system("ConstructibleSystem")
		if constructible_system != null:
			constructible_system.worker = null
	
	target_entity = value
	
	if target_entity != null:
		var sitelen_system: SitelenSystem = target_entity.get_system("SitelenSystem")
		if sitelen_system != null:
			sitelen_system.interact_with(entity)
		
		var mineable_system: MineableSystem = target_entity.get_system("MineableSystem")
		if mineable_system != null:
			mineable_system.worker = entity
		
		var constructible_system: ConstructibleSystem = \
				target_entity.get_system("ConstructibleSystem")
		if constructible_system != null:
			constructible_system.worker = entity
	
	_update_hints()


func _on_selected_changed() -> void:
	_update_hints()
