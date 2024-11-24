extends "res://entities/entity_system.gd"


const InventorySystem := preload("res://entities/inventory_system.gd")
const EntityPossess := preload("res://ui/hints/entity_possess.gd")

@export var textures: Array[Texture2D] = []

var texture_map := {
	&"": 0,
	&"tool": 1,
	&"stone": 2,
}

var _is_running := false
var _hint_possess: EntityPossess
var _audio_action: AudioStreamPlayer
var _sprite_content: Sprite2D
var _inventory: InventorySystem


func start() -> void:
	_hint_possess = entity.get_node_or_null("HintPossess")
	_sprite_content = entity.get_node_or_null("SpriteContent")
	_audio_action = entity.get_node_or_null("AudioAction")
	_inventory = entity.get_system("InventorySystem")
	
	_inventory.items_changed.connect(_on_inventory_items_changed)
	_on_inventory_items_changed()
	
	_is_running = true


func destroy() -> void:
	_inventory.items_changed.disconnect(_on_inventory_items_changed)


func _on_inventory_items_changed() -> void:
	if _sprite_content != null:
		_sprite_content.texture = textures[texture_map.get(_inventory.item_type, 0)]
	
	if _hint_possess != null:
		var old_active := _hint_possess.active
		var new_active := (_inventory.item_type != "")
		if old_active != new_active:
			_hint_possess.active = new_active
	
	if _is_running and _audio_action != null:
		_audio_action.play()
