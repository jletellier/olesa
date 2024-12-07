extends Node2D


const Entity := preload("res://entities/entity.gd")
const EntityDB := preload("res://entities/entity_db.gd")
const EntitySystem := preload("res://entities/entity_system.gd")
const SelectableSystem := preload("res://entities/selectable_system.gd")
const SurfaceSystem := preload("res://entities/surface_system.gd")

const TILE_EMPTY := Vector2i(-1, -1)

signal goals_reached()

@warning_ignore("unused_signal")
signal dialogue_triggered(text: String, placement_top: bool)

var _entity_map := {} # Typing: Dictionary[Vector3i, Entity]
var _selectable_systems: Array[SelectableSystem] = []
var _selected_system: SelectableSystem
var _surface_system_count := 0
var _surface_system_finished_count := 0
var _history := []
var _history_transaction := []
var _history_undo_process := false
var _is_running := false

@onready var _block_layer := $"BlockLayer" as TileMapLayer
@onready var _entities_container := $"Entities" as Node2D


func _ready() -> void:
	_convert_entities()
	tick()
	
	_is_running = true
	
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
	
	select_next.call_deferred()


func _history_transaction_add(step: Array) -> void:
	if _history_undo_process:
		return
	
	_history_transaction.append(step)


func _history_transaction_undo(transaction := []) -> void:
	if transaction.size() == 0:
		transaction = _history_transaction
	
	_history_undo_process = true
	for i in range(transaction.size() - 1, -1, -1):
		var step: Array = transaction[i]
		var type: String = step[0]
		
		if type == "system_update":
			var entity_pos: Vector3i = step[1]
			var system: String = step[2]
			var attribute: String = step[3]
			var value: Variant = step[4]
			
			var entity := get_entity(Vector2i(entity_pos.x, entity_pos.y), entity_pos.z)
			var entity_system := entity.get_system(system)
			if entity_system != null and attribute in entity_system:
				entity_system.set(attribute, value)
		elif type == "remove_entity":
			var entity_pos: Vector2i = step[1]
			var entity_name: StringName = step[2]
			var entity_data: Dictionary = step[3]
			
			var entity_type := EntityDB.get_by_name(entity_name)
			add_entity(entity_pos, entity_type, entity_data)
		elif type == "selected_entity":
			var entity_pos: Vector3i = step[1]
			var entity := get_entity(Vector2i(entity_pos.x, entity_pos.y), entity_pos.z)
			if entity != null:
				var entity_system: SelectableSystem = entity.get_system("SelectableSystem")
				if entity_system != _selected_system:
					entity_system.selected = true
	
	tick()
	_history_undo_process = false
	_history_transaction = []


func _history_transaction_save() -> void:
	if _history_transaction.size() == 0:
		return
	
	if _selected_system != null:
		var entity_pos := Vector3i(
			_selected_system.entity.pos.x,
			_selected_system.entity.pos.y, 
			_selected_system.entity.layer,
		)
		var history_step = ["selected_entity", entity_pos]
		_history_transaction_add(history_step)

	_history.push_back(_history_transaction)
	_history_transaction = []


func tick() -> void:
	for entity in _entity_map.values():
		if entity is Entity:
			entity.tick()
	
	if _history_transaction.size() > 0:
		_history_transaction_save()


func step_process(delta: float, duration: float) -> void:
	for entity in _entity_map.values():
		if entity is Entity:
			entity.step_process(delta, duration)


func action(dir: Vector2i) -> bool:
	if dir != Vector2i.ZERO and _selected_system != null:
		return _selected_system.entity.action(dir)
	
	return false


func history_undo() -> void:
	if _history.is_empty():
		return
	
	var transaction := _history.pop_back() as Array
	_history_transaction_undo(transaction)


func get_moore_neighbors(pos: Vector2i, layer := 0) -> Array[Entity]:
	var neighbors: Array[Entity] = []
	var surrounding_positions := _block_layer.get_surrounding_cells(pos)
	for surrounding_pos in surrounding_positions:
		var entity := get_entity(surrounding_pos, layer)
		if entity != null:
			neighbors.append(entity)
	
	return neighbors


func select_next() -> void:
	if _selectable_systems.is_empty():
		return
	
	var current_idx := -1
	if _selected_system != null:
		for i in range(_selectable_systems.size()):
			var entity := _selectable_systems[i].entity
			if entity.pos == _selected_system.entity.pos:
				current_idx = i
				break
	
	var next_idx := (current_idx + 1) % _selectable_systems.size()
	var new_selected_system := _selectable_systems[next_idx]
	new_selected_system.selected = true


func set_selected_system(new_system: SelectableSystem) -> void:
	if _selected_system != null:
		_selected_system.selected = false
	
	if new_system != null:
		_selected_system = new_system


func add_entity(pos: Vector2i, type: Dictionary, data := {}) -> void:
	var scene := type.scene as PackedScene
	var entity := scene.instantiate() as Entity
	entity.position = _block_layer.map_to_local(pos)
	entity.pos = pos
	_entities_container.add_child(entity)
	
	_entity_map[Vector3i(pos.x, pos.y, entity.layer)] = entity
	
	entity.type = type.name
	entity.map = self
	entity.history_transaction.connect(_on_history_transaction)
	entity.init(data)
	
	if _is_running:
		entity.tick()
		entity.tick()
	
	var selectable_system: SelectableSystem = entity.get_system("SelectableSystem")
	if selectable_system != null:
		_selectable_systems.append(selectable_system)
	
	var surface_system: SurfaceSystem = entity.get_system("SurfaceSystem")
	if surface_system != null:
		_surface_system_count += 1
		surface_system.has_object_changed.connect(_on_surface_system_has_object_changed)


func remove_entity(entity: Entity) -> void:
	var selectable_system: SelectableSystem = entity.get_system("SelectableSystem")
	if selectable_system != null:
		_selectable_systems.erase(selectable_system)
	
	var surface_system: SurfaceSystem = entity.get_system("SurfaceSystem")
	if surface_system != null:
		_surface_system_count -= 1
		surface_system.has_object_changed.disconnect(_on_surface_system_has_object_changed)
	
	entity.history_transaction.disconnect(_on_history_transaction)
	
	var history_step = ["remove_entity", entity.pos, entity.type, entity.serialize()]
	_history_transaction_add(history_step)
	
	_entity_map.erase(Vector3i(entity.pos.x, entity.pos.y, entity.layer))
	entity.queue_free()
	
	if selectable_system == _selected_system:
		select_next()


func move_entity(entity: Entity, old_pos: Vector2i, old_layer: int) -> void:
	entity.position = _block_layer.map_to_local(entity.pos)
	
	if _entity_map.erase(Vector3i(old_pos.x, old_pos.y, old_layer)):
		_entity_map[Vector3i(entity.pos.x, entity.pos.y, entity.layer)] = entity


func get_entity(pos: Vector2i, layer := 0) -> Entity:
	return _entity_map.get(Vector3i(pos.x, pos.y, layer))


func get_entities_with_system(system: String) -> Array[Entity]:
	var entities: Array[Entity] = []
	
	for entity in _entity_map.values():
		if entity is Entity:
			if entity.get_system(system) != null:
				entities.append(entity)
	
	return entities


func get_cell(pos: Vector2i) -> Vector2i:
	return _block_layer.get_cell_atlas_coords(pos)


func set_cell(pos: Vector2i, cell: Vector2i) -> void:
	_block_layer.set_cell(pos, 0, cell)


func get_map_size() -> Vector2i:
	return _block_layer.get_used_rect().size


func get_tile_size() -> Vector2i:
	return _block_layer.tile_set.tile_size


func _on_history_transaction(
		entity: Entity, system: String, attribute: String, value: Variant) -> void:
	var entity_pos := Vector3i(entity.pos.x, entity.pos.y, entity.layer)
	var step := ["system_update", entity_pos, system, attribute, value]
	_history_transaction_add(step)


func _on_surface_system_has_object_changed(_old_value: bool, new_value: bool) -> void:
	if new_value:
		_surface_system_finished_count += 1
	else:
		_surface_system_finished_count -= 1
	
	if _surface_system_count > 0 and _surface_system_finished_count >= _surface_system_count:
		goals_reached.emit.call_deferred()
