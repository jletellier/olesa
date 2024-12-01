extends "res://entities/entity_system.gd"


const InventorySystem := preload("res://entities/inventory_system.gd")

signal is_open_changed()

@export var texture_door: Texture2D
@export var texture_hint: Texture2D

var is_open := false:
	set = _set_is_open


var _sprite: Sprite2D


func start() -> void:
	_sprite = entity.get_node("Sprite2D")
	
	_set_is_open(is_open)


func tick() -> void:
	if is_open and entity.map.get_entity(entity.pos) != null:
		return
	
	var neighbors := entity.map.get_moore_neighbors(entity.pos)
	var found_tool := false
	for neighbor in neighbors:
		var neighbor_inventory: InventorySystem = neighbor.get_system("InventorySystem")
		if neighbor_inventory != null and neighbor_inventory.item_type == "tool":
			found_tool = true
			break
	
	is_open = found_tool


func _set_is_open(value: bool) -> void:
	var old_value := is_open
	is_open = value
	entity.layer = 1 if is_open else 0
	
	if old_value != value:
		is_open_changed.emit()
		emit_history_transaction("is_open", old_value)
	
	if _sprite != null:
		_sprite.texture = texture_hint if is_open else texture_door
