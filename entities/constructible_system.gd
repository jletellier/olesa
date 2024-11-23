extends "res://entities/entity_system.gd"


const EntityProgress := preload("res://ui/hints/entity_progress.gd")
const EntityPossess := preload("res://ui/hints/entity_possess.gd")
const InventorySystem := preload("res://entities/inventory_system.gd")

@export var processing_count := 3
@export var target_item_name: StringName

var processing_step := 0

var worker: Entity:
	set = _set_worker

var _hint_progress: EntityProgress
var _audio_finish: AudioStreamPlayer
var _inventory: InventorySystem


func start() -> void:
	_hint_progress = entity.get_node("HintProgress")
	_audio_finish = entity.get_node("AudioFinish")
	_inventory = entity.get_system("InventorySystem")


func tick() -> void:
	if worker != null and _inventory.item_type == "tool":
		processing_step += 1
		_update_hints()
		
		if processing_step >= processing_count:
			_inventory.retrieve_item()
			processing_step = 0
			_audio_finish.play()
			_construction_finished()


func _construction_finished() -> void:
	entity.map.remove_entity(entity)
	
	var target_item_type := entity.EntityDB.get_by_name(target_item_name)
	entity.map.add_entity(entity.pos, target_item_type)


func _update_hints() -> void:
	if _hint_progress != null:
		_hint_progress.visible = (worker != null)
		_hint_progress.progress = processing_step


func _set_worker(value: Entity) -> void:
	worker = value
	processing_step = 0
	_update_hints()
