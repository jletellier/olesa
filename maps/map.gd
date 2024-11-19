extends Node2D


const Entity := preload("res://entities/entity.gd")
const EntityDB := preload("res://entities/entity_db.gd")

const TILE_EMPTY := Vector2i(-1, -1)

var _entity_map := {} # Typing: Dictionary[Vector3i, Entity]
var _process_entities: Array[Entity] = []
var _selectable_entities: Array[Entity] = []
var _selected_entity: Entity
var _history := []
var _history_transaction := []
var _history_undo_process := false

@onready var _block_layer := $"BlockLayer" as TileMapLayer
@onready var _entities_container := $"Entities" as Node2D


func _ready() -> void:
	_convert_entities()
	_process_logic()
	
	# Workaround, only for editing purposes; allows to run a map on its own
	if OS.has_feature("editor") and get_tree().root.get_child(0) == self:
		(func():
			var LevelScene := load("res://level/level.tscn")
			var level_node := LevelScene.instantiate() as Node
			level_node.remove_child(level_node.get_node("Map"))
			var root_node := get_tree().root
			root_node.remove_child(self)
			level_node.add_child(self)
			root_node.add_child(level_node)
		).call_deferred()


func _convert_entities() -> void:
	var cell_positions := _block_layer.get_used_cells()
	for cell_pos in cell_positions:
		var cell := _block_layer.get_cell_atlas_coords(cell_pos)
		if cell in EntityDB.SceneMap:
			var scene_item := EntityDB.SceneMap[cell] as Dictionary
			var entity_scene := scene_item.scene as PackedScene
			var entity_data := scene_item.get("data", {}) as Dictionary
			add_entity(cell_pos, entity_scene, entity_data)
			
			# Remove tile, since it's no longer needed
			_block_layer.erase_cell(cell_pos)


func _history_transaction_add(entity: Entity, attribute: String, value: Variant) -> void:
	if _history_undo_process:
		return
	
	var step := [entity, attribute, value]
	_history_transaction.append(step)


func _history_transaction_undo(transaction := []) -> void:
	if transaction.size() == 0:
		transaction = _history_transaction
	
	_history_undo_process = true
	for i in range(transaction.size() - 1, -1, -1):
		var step: Array = transaction[i]
		var entity: Entity = step[0]
		var attribute: String = step[1]
		var value: Variant = step[2]
		
		entity.set(attribute, value)
	
	_history_undo_process = false
	_history_transaction = []


func _history_transaction_save() -> void:
	if _history_transaction.size() == 0:
		return

	_history.push_back(_history_transaction)
	_history_transaction = []


func _process_logic() -> void:
	for entity in _process_entities:
		entity.process_logic()


func process_action(dir: Vector2i) -> void:
	if dir != Vector2i.ZERO and _selected_entity != null:
		_selected_entity.process_action(dir)
		if _history_transaction.size() > 0:
			_process_logic()
			_history_transaction_save()


func history_undo() -> void:
	if _history.is_empty():
		return
	
	var transaction := _history.pop_back() as Array
	_history_transaction_undo(transaction)


func get_moore_neighbors(pos: Vector2i, layer := 0) -> Array[Entity]:
	var neighbors: Array[Entity] = []
	var surrounding_positions := _block_layer.get_surrounding_cells(pos)
	for surrounding_pos in surrounding_positions:
		var entity: Entity = _entity_map.get(
				Vector3i(surrounding_pos.x, surrounding_pos.y, layer))
		if entity != null:
			neighbors.append(entity)
	
	return neighbors


func select_next_entity() -> void:
	if _selectable_entities.is_empty():
		return
	
	var current_idx := -1
	if _selected_entity != null:
		_selected_entity.selected = false
		
		for i in range(_selectable_entities.size()):
			var entity := _selectable_entities[i]
			if entity.pos == _selected_entity.pos:
				current_idx = i
				break
	
	var next_idx := (current_idx + 1) % _selectable_entities.size()
	_selected_entity = _selectable_entities[next_idx]
	_selected_entity.selected = true


func add_entity(pos: Vector2i, scene: PackedScene, data := {}) -> void:
	var entity := scene.instantiate() as Entity
	entity.position = _block_layer.map_to_local(pos)
	entity.pos = pos
	for attribute in data:
		if attribute in entity:
			entity.set(attribute, data[attribute])
	_entities_container.add_child(entity)
	
	_entity_map[Vector3i(pos.x, pos.y, entity.layer)] = entity
	
	if entity.process:
		_process_entities.append(entity)
	
	if entity.selectable:
		_selectable_entities.append(entity)
	
	entity.map = self
	entity.history_transaction.connect(_history_transaction_add)
	
	if _selected_entity == null:
		select_next_entity()


func remove_entity(entity: Entity) -> void:
	if entity.process:
		_process_entities.erase(entity)
		
	if entity.selectable:
		_selectable_entities.erase(entity)
	
	entity.history_transaction.disconnect(_history_transaction_add)
	
	_entity_map.erase(Vector3i(entity.pos.x, entity.pos.y, entity.layer))
	entity.queue_free()
	
	if entity == _selected_entity:
		select_next_entity()


func move_entity(entity: Entity, old_pos: Vector2i) -> void:
	entity.position = _block_layer.map_to_local(entity.pos)
	
	if _entity_map.erase(Vector3i(old_pos.x, old_pos.y, 0)):
		_entity_map[Vector3i(entity.pos.x, entity.pos.y, 0)] = entity
	
	#if entity == _selected_entity:
		#update_hints()


func cascade_push(current_pos: Vector2i, dir: Vector2i) -> void:
	var target_pos := current_pos + dir
	
	var current_entity: Entity = _entity_map.get(Vector3i(current_pos.x, current_pos.y, 0))
	var cascade_entity: Entity = _entity_map.get(Vector3i(target_pos.x, target_pos.y, 0))
	
	# Cascade push as long as there are entities
	if current_entity != null and cascade_entity != null:
		if current_entity.can_push(cascade_entity):
			cascade_push(target_pos, dir)
		
		current_entity.collide_with(cascade_entity)
		cascade_entity.collide_with(current_entity)
	
	# Fetch target cell/entity again, in case it has been moved/removed
	var target_cell := get_cell(target_pos)
	var target_entity: Entity = _entity_map.get(Vector3i(target_pos.x, target_pos.y, 0))
	
	# Action: Target is empty
	if target_cell == TILE_EMPTY and target_entity == null:
		current_entity.pos = target_pos


func get_cell(pos: Vector2i) -> Vector2i:
	return _block_layer.get_cell_atlas_coords(pos)


func set_cell(pos: Vector2i, cell: Vector2i) -> void:
	_block_layer.set_cell(pos, 0, cell)


func get_map_size() -> Vector2i:
	return _block_layer.get_used_rect().size


func get_tile_size() -> Vector2i:
	return _block_layer.tile_set.tile_size
