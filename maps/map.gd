extends Node2D


const Entity := preload("res://entities/entity.gd")
const EntityDB := preload("res://entities/entity_db.gd")
const SelectableSystem := preload("res://entities/selectable_system.gd")

const TILE_EMPTY := Vector2i(-1, -1)

var _entity_map := {} # Typing: Dictionary[Vector3i, Entity]
var _selectable_systems: Array[SelectableSystem] = []
var _selected_system: SelectableSystem
var _history := []
var _history_transaction := []
var _history_undo_process := false

@onready var _block_layer := $"BlockLayer" as TileMapLayer
@onready var _entities_container := $"Entities" as Node2D


func _ready() -> void:
	_convert_entities()
	_process_tick()
	
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
		var entity_type := EntityDB.get_by_atlas_coords(cell)
		if entity_type != {}:
			var entity_data := entity_type.get("data", {}) as Dictionary
			add_entity(cell_pos, entity_type, entity_data)
			
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


func _process_tick() -> void:
	for entity in _entity_map.values():
		if entity is Entity:
			entity.tick()


func process_action(dir: Vector2i) -> void:
	if dir != Vector2i.ZERO and _selected_system != null:
		_selected_system.entity.action(dir)
		if _history_transaction.size() > 0:
			_process_tick()
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


func select_next() -> void:
	if _selectable_systems.is_empty():
		return
	
	var current_idx := -1
	if _selected_system != null:
		_selected_system.selected = false
		
		for i in range(_selectable_systems.size()):
			var entity := _selectable_systems[i].entity
			if entity.pos == _selected_system.entity.pos:
				current_idx = i
				break
	
	var next_idx := (current_idx + 1) % _selectable_systems.size()
	_selected_system = _selectable_systems[next_idx]
	_selected_system.selected = true


func add_entity(pos: Vector2i, type: Dictionary, data := {}) -> void:
	var scene := type.scene as PackedScene
	var entity := scene.instantiate() as Entity
	entity.position = _block_layer.map_to_local(pos)
	entity.pos = pos
	_entities_container.add_child(entity)
	
	_entity_map[Vector3i(pos.x, pos.y, entity.layer)] = entity
	
	entity.type = type.name
	entity.map = self
	entity.history_transaction.connect(_history_transaction_add)
	entity.init(data)
	
	var selectable_system := entity.get_system("SelectableSystem")
	if selectable_system is SelectableSystem:
		_selectable_systems.append(selectable_system)
	
	if _selected_system == null:
		select_next()


func remove_entity(entity: Entity) -> void:
	var selectable_system := entity.get_system("SelectableSystem")
	if selectable_system is SelectableSystem:
		_selectable_systems.erase(selectable_system)
	
	entity.history_transaction.disconnect(_history_transaction_add)
	
	_entity_map.erase(Vector3i(entity.pos.x, entity.pos.y, entity.layer))
	entity.queue_free()
	
	if selectable_system == _selected_system:
		select_next()


func move_entity(entity: Entity, old_pos: Vector2i) -> void:
	entity.position = _block_layer.map_to_local(entity.pos)
	
	if _entity_map.erase(Vector3i(old_pos.x, old_pos.y, 0)):
		_entity_map[Vector3i(entity.pos.x, entity.pos.y, 0)] = entity


func get_entity(pos: Vector2i, layer := 0) -> Entity:
	return _entity_map.get(Vector3i(pos.x, pos.y, layer))


func get_cell(pos: Vector2i) -> Vector2i:
	return _block_layer.get_cell_atlas_coords(pos)


func set_cell(pos: Vector2i, cell: Vector2i) -> void:
	_block_layer.set_cell(pos, 0, cell)


func get_map_size() -> Vector2i:
	return _block_layer.get_used_rect().size


func get_tile_size() -> Vector2i:
	return _block_layer.tile_set.tile_size
