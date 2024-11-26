extends "res://entities/entity_system.gd"


const SitelenSystem := preload("res://entities/sitelen_system.gd")
const MoveableSystem := preload("res://entities/moveable_system.gd")
const InventorySystem := preload("res://entities/inventory_system.gd")

@export var textures: Array[Texture2D] = []

var sitelen_id: int
var shift_type: StringName

var _audio_destroy: AudioStreamPlayer
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


func tick() -> void:
	if entity.layer == 1:
		if entity.map.get_entity(entity.pos) == null:
			entity.layer = 0


func start() -> void:
	_audio_destroy = entity.get_node("AudioDestroy")
	_sprite = entity.get_node("Sprite2D")
	_sprite.texture = textures[sitelen_id]
	
	_moveable_system = entity.get_system("MoveableSystem")
	_moveable_system.collided_with.connect(_on_collided_with)


func destroy() -> void:
	_moveable_system.collided_with.disconnect(_on_collided_with)


func interact_with(other: Entity) -> void:
	# Pali can bring lawa sitelen to life
	if other.type == "pali" and sitelen_id == 7:
		entity.map.remove_entity(entity)
		entity.map.add_entity(entity.pos, entity.EntityDB.get_by_name("lawa"))
	
	# Jo can go interact with sitelen
	if other.type == "jo" and sitelen_id == 16:
		var inventory: InventorySystem = other.get_system("InventorySystem")
		if inventory != null:
			inventory.store_item("tool")


func _on_collided_with(other: Entity) -> void:
	# Jo can go through sitelen
	if other.type == "jo":
		if sitelen_id == 0:
			entity.layer = 1
		elif sitelen_id == 11:
			# Simulate door
			var inventory: InventorySystem = other.get_system("InventorySystem")
			if inventory != null and inventory.item_type == &"tool":
				entity.layer = 1
			else:
				var neighbors := entity.map.get_moore_neighbors(entity.pos)
				for neighbor in neighbors:
					var neighbor_inventory: InventorySystem = neighbor.get_system("InventorySystem")
					if neighbor_inventory != null and neighbor_inventory.item_type == "tool":
						entity.layer = 1
						break
	
	# Two lawas colliding causes them both to disappear
	if other.type == "lawa" and sitelen_id == 7:
		entity.map.remove_entity(entity)
		entity.map.remove_entity(other)
		_audio_destroy.reparent(entity.get_parent())
		_audio_destroy.play()
