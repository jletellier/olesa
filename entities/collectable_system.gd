extends "res://entities/entity_system.gd"


const InventorySystem := preload("res://entities/inventory_system.gd")
const SitelenSystem := preload("res://entities/sitelen_system.gd")

var _inventory: InventorySystem


func start() -> void:
	_inventory = entity.get_system("InventorySystem")


func action(dir: Vector2i) -> bool:
	var target_pos := entity.pos + dir
	var neighbor: Entity = entity.map._entity_map.get(Vector3i(target_pos.x, target_pos.y, 0))
	
	if neighbor == null:
		return false
	
	var sitelen_system: SitelenSystem = neighbor.get_system("SitelenSystem")
	if sitelen_system != null:
		sitelen_system.interact_with(entity)
	
	var neighbor_inventory: InventorySystem = neighbor.get_system("InventorySystem")
	if neighbor_inventory == null:
		return false
	
	if neighbor_inventory.can_retrieve_item() and _inventory.can_store_item():
		var item_type := neighbor_inventory.retrieve_item()
		_inventory.store_item(item_type)
	elif _inventory.can_retrieve_item() and neighbor_inventory.can_store_item():
		var item_type := _inventory.retrieve_item()
		neighbor_inventory.store_item(item_type)
	
	return true
