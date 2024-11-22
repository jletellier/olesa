extends "res://entities/entity_system.gd"


signal items_changed()

@export var item_type: StringName:
	get: return _item_type
	set(value):
		var changed := (_item_type != value)
		_item_type = value
		if changed:
			items_changed.emit()

## Indicates whether items can be stored in this inventory.
## Set this to false for collectable resources.
@export var can_store := true

## Indicates whether items can be retrieved from this inventory.
@export var can_retrieve := true

var _item_type: StringName


func init(data := {}) -> void:
	_item_type = data.get("item_type", &"")


func serialize() -> Dictionary:
	return {
		"item_type": _item_type
	}


func can_store_item() -> bool:
	if !can_store:
		return false
	
	if item_type != "":
		return false
	
	return true


func can_retrieve_item(type := &"") -> bool:
	if !can_retrieve:
		return false
	
	if type != &"" and type != item_type:
		return false
	
	if item_type == &"":
		return false
	
	return true


func store_item(type: StringName):
	if can_store_item():
		item_type = type


func retrieve_item() -> StringName:
	if can_retrieve_item():
		var old_item_type := item_type
		item_type = &""
		return old_item_type
	
	return &""
