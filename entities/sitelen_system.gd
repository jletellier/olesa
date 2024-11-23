extends "res://entities/entity_system.gd"


const SitelenSystem := preload("res://entities/sitelen_system.gd")
const MoveableSystem := preload("res://entities/moveable_system.gd")
const InventorySystem := preload("res://entities/inventory_system.gd")

@export var textures: Array[Texture2D] = []

var sitelen_id: int
var shift_type: StringName

var _sprite: Sprite2D
var _moveable_system: MoveableSystem


func init(data := {}) -> void:
	sitelen_id = data.get("sitelen_id", 0)
	shift_type = data.get("shift_type", &"")


func serialize() -> Dictionary:
	return {
		"sitelen_id": sitelen_id,
		"shift_type": shift_type,
	}


func start() -> void:
	_sprite = entity.get_node("Sprite2D")
	_sprite.texture = textures[sitelen_id]
	
	_moveable_system = entity.get_system("MoveableSystem")
	_moveable_system.collided_with.connect(_on_collided_with)


func destroy() -> void:
	_moveable_system.collided_with.disconnect(_on_collided_with)


func shift() -> void:
	entity.map.remove_entity(entity)
	var entity_type := entity.EntityDB.get_by_name(shift_type)
	if !entity_type.is_empty():
		entity.map.add_entity(entity.pos, entity_type)


func _on_collided_with(other: Entity) -> void:
	if sitelen_id == 11 and other.type == "jo":
		var inventory: InventorySystem = other.get_system("InventorySystem")
		if inventory != null and inventory.item_type == "tool":
			var entities := entity.map.get_entities_with_system("SitelenSystem")
			for sitelen_entity in entities:
				var system: SitelenSystem = sitelen_entity.get_system("SitelenSystem")
				system.shift()
