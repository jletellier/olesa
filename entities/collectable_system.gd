extends "res://entities/entity_system.gd"


const CollectableSystem := preload("res://entities/collectable_system.gd")
const InventorySystem := preload("res://entities/inventory_system.gd")
const EntityPossess := preload("res://ui/hints/entity_possess.gd")

var _hint_possess: EntityPossess
var _audio_action: AudioStreamPlayer
var _inventory: InventorySystem


func start() -> void:
	_hint_possess = entity.get_node("HintPossess")
	_audio_action = entity.get_node("AudioAction")
	_inventory = entity.get_system("InventorySystem")


func action(dir: Vector2i) -> void:
	var target_pos := entity.pos + dir
	var neighbor: Entity = entity.map._entity_map.get(Vector3i(target_pos.x, target_pos.y, 0))
	
	if neighbor == null:
		return
	
	var neighbor_inventory: InventorySystem = neighbor.get_system("InventorySystem")
	if neighbor_inventory == null:
		return
	
	if neighbor_inventory.can_retrieve_item() and _inventory.can_store_item():
		var item_type := neighbor_inventory.retrieve_item()
		_inventory.store_item(item_type)
	elif _inventory.can_retrieve_item() and neighbor_inventory.can_store_item():
		var item_type := _inventory.retrieve_item()
		neighbor_inventory.store_item(item_type)