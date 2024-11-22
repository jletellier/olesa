extends "res://entities/entity_system.gd"


const InventorySystem := preload("res://entities/inventory_system.gd")
const EntityPossess := preload("res://ui/hints/entity_possess.gd")

@export var sprite_tool: Texture2D

var _hint_possess: EntityPossess
var _sprite_content: Sprite2D
var _inventory: InventorySystem


func start() -> void:
	_hint_possess = entity.get_node_or_null("HintPossess")
	_sprite_content = entity.get_node_or_null("SpriteContent")
	_inventory = entity.get_system("InventorySystem")
	
	if _inventory != null:
		_inventory.items_changed.connect(_on_inventory_items_changed)
		_on_inventory_items_changed()


func destroy() -> void:
	if _inventory != null:
		_inventory.items_changed.disconnect(_on_inventory_items_changed)


func _on_inventory_items_changed() -> void:
	if _hint_possess != null:
		_hint_possess.active = (_inventory.item_type != "")
	
	if _sprite_content != null:
		_sprite_content.texture = sprite_tool if (_inventory.item_type != "") else null
