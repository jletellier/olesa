extends Node2D


const Entity := preload("res://entities/entity.gd")
const EntitySelect := preload("res://ui/hints/entity_select.gd")
const EntityDB := preload("res://entities/entity_db.gd")

const TILE_EMPTY := Vector2i(-1, -1)

var _entity_map := {} # Typing: Dictionary[Vector3i, Entity]
var _process_entities: Array[Entity] = []
var _selectable_entities: Array[Entity] = []
var _selected_entity: Entity
var _history := []
var _history_transaction := []

@onready var _block_layer := $"BlockLayer" as TileMapLayer
@onready var _entities_container := $"Entities" as Node2D
@onready var _hint_entity_select := $Hints/EntitySelect as EntitySelect


func _ready() -> void:
	_convert_entities()
	_process_logic()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		select_next_entity()
	
	if event.is_action_pressed("game_undo"):
		history_undo()
	
	var action_dir := Vector2i.ZERO
	
	if event.is_action_pressed("game_right"):
		action_dir = Vector2i.RIGHT
	elif event.is_action_pressed("game_down"):
		action_dir = Vector2i.DOWN
	elif event.is_action_pressed("game_left"):
		action_dir = Vector2i.LEFT
	elif event.is_action_pressed("game_up"):
		action_dir = Vector2i.UP
	
	if action_dir != Vector2i.ZERO and _selected_entity != null:
		_selected_entity.process_action(action_dir)
		if _history_transaction.size() == 0:
			_process_logic()
		_history_transaction_save()


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


func _history_transaction_add(coords: Vector3i,
		entity: Entity = null, old_cell := TILE_EMPTY) -> void:
	var step := [coords, entity, old_cell]
	_history_transaction.append(step)


func _history_transaction_undo(transaction := []) -> void:
	if transaction.size() == 0:
		transaction = _history_transaction
	
	for i in range(transaction.size() - 1, -1, -1):
		var step := transaction[i] as Array
		var coords := step[0] as Vector3i
		var pos := Vector2i(coords.x, coords.y)
		var layer := coords.z
		var entity := step[1] as Entity
		var old_cell := step[2] as Vector2i
		
		if entity != null:
			move_cell(entity.pos, pos)
	
	_history_transaction = []


func _history_transaction_save() -> void:
	if _history_transaction.size() == 0:
		return

	_history.push_back(_history_transaction)
	_history_transaction = []


func _process_logic() -> void:
	for entity in _process_entities:
		entity.process_logic()


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


func update_hints(animate := false) -> void:
	if _selected_entity == null:
		_hint_entity_select.visible = false
		return
	
	_hint_entity_select.visible = true
	_hint_entity_select.position = _block_layer.map_to_local(_selected_entity.pos)
	if animate:
		_hint_entity_select.animate()


func select_next_entity() -> void:
	if _selectable_entities.is_empty():
		return
	
	var current_idx := -1
	if _selected_entity != null:
		for i in range(_selectable_entities.size()):
			var entity := _selectable_entities[i]
			if entity.pos == _selected_entity.pos:
				current_idx = i
				break
	
	var next_idx := (current_idx + 1) % _selectable_entities.size()
	_selected_entity = _selectable_entities[next_idx]
	
	update_hints(true)


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
	
	if _selected_entity == null:
		select_next_entity()


func remove_entity(entity: Entity) -> void:
	if entity.selectable:
		_selectable_entities.erase(entity)
	
	_entity_map.erase(Vector3i(entity.pos.x, entity.pos.y, entity.layer))
	entity.queue_free()
	
	if entity == _selected_entity:
		select_next_entity()


func move_entity(entity: Entity, dir: Vector2i) -> void:
	cascade_push(entity.pos, dir)


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
		move_cell(current_pos, target_pos)


func move_cell(current_pos: Vector2i, target_pos: Vector2i) -> void:
	var current_entity: Entity = _entity_map.get(Vector3i(current_pos.x, current_pos.y, 0))
	
	# Move entity
	if current_entity != null:
		current_entity.pos = target_pos
		current_entity.position = _block_layer.map_to_local(target_pos)
		
		_entity_map.erase(Vector3i(current_pos.x, current_pos.y, 0))
		_entity_map[Vector3i(target_pos.x, target_pos.y, 0)] = current_entity
		
		if current_entity == _selected_entity:
			update_hints()
		
		_history_transaction_add(Vector3i(current_pos.x, current_pos.y, 0), current_entity)
		return
	
	# Otherwise move tile
	var current_cell := get_cell(current_pos)
	if current_cell != TILE_EMPTY:
		set_cell(current_pos, TILE_EMPTY)
		set_cell(target_pos, current_cell)
		_history_transaction_add(Vector3i(current_pos.x, current_pos.y, 0), null, current_cell)
		return


func get_cell(pos: Vector2i) -> Vector2i:
	return _block_layer.get_cell_atlas_coords(pos)


func set_cell(pos: Vector2i, cell: Vector2i) -> void:
	_block_layer.set_cell(pos, 0, cell)
