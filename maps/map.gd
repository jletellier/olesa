extends Node2D


const Entity := preload("res://entities/entity.gd")
const EntitySelect := preload("res://ui/hints/entity_select.gd")
const EntityDB := preload("res://entities/entity_db.gd")

const TILE_EMPTY := Vector2i(-1, -1)
const TILE_WALL := Vector2i(0, 0)
const TILE_PLAYER := Vector2i(1, 0)
const TILE_OBJECT := Vector2i(2, 0)
const TILE_SURFACE := Vector2i(3, 0)
const TILE_SURFACE_OBJECT := Vector2i(4, 0)
const TILE_WALL_CRACKED := Vector2i(5, 0)
const TILE_DOOR := Vector2i(6, 0)
const TILE_CONTAINER := Vector2i(7, 2)
const TILE_CONTAINER_TOOL := Vector2i(7, 0)

const HINT_DOOR := Vector2i(6, 1)

var _entity_map := {} # Typing: Dictionary[Vector2i, Entity]
var _process_entities: Array[Entity] = []
var _selectable_entities: Array[Entity] = []
var _selected_entity: Entity

@onready var _block_layer := $"BlockLayer" as TileMapLayer
@onready var _hint_layer := $"HintLayer" as TileMapLayer
@onready var _entities_container := $"Entities" as Node2D
@onready var _hint_entity_select := $Hints/EntitySelect as EntitySelect


func _ready() -> void:
	_convert_entities()
	_process_logic()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		select_next_entity()
	
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


func _convert_entities() -> void:
	var cell_positions := _block_layer.get_used_cells()
	for cell_pos in cell_positions:
		var cell := _block_layer.get_cell_atlas_coords(cell_pos)
		if cell in EntityDB.SceneMap:
			var entity_scene := EntityDB.SceneMap[cell] as PackedScene
			add_entity(cell_pos, entity_scene)
			
			# Remove tile, since it's no longer needed
			_block_layer.erase_cell(cell_pos)


func _process_logic() -> void:
	for entity in _process_entities:
		entity.process_logic()
	# Process: Open/close doors depending on whether a tool is nearby
	#var used_positions := _hint_layer.get_used_cells_by_id(0, HINT_DOOR)
	#for hint_pos in used_positions:
		#var block_cell := get_cell(hint_pos)
		#if block_cell != TILE_DOOR and block_cell != TILE_EMPTY:
			#continue
		#
		#var has_tool := false
		#var surrounding_positions := _hint_layer.get_surrounding_cells(hint_pos)
		#for surrounding_pos in surrounding_positions:
			#var surrounding_cell := get_cell(surrounding_pos)
			#if surrounding_cell == TILE_CONTAINER_TOOL:
				#has_tool = true
				#break
		#
		#set_cell(hint_pos, TILE_EMPTY if has_tool else TILE_DOOR)


func _get_moore_neighbors(pos: Vector2i) -> Array[Entity]:
	var neighbors: Array[Entity] = []
	var surrounding_positions := _block_layer.get_surrounding_cells(pos)
	for surrounding_pos in surrounding_positions:
		var entity := _entity_map.get(surrounding_pos) as Entity
		if entity is Entity:
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


func add_entity(pos: Vector2i, scene: PackedScene) -> void:
	var entity := scene.instantiate() as Entity
	entity.position = _block_layer.map_to_local(pos)
	entity.pos = pos
	entity.move_requested.connect(_on_entity_move_requested.bind(entity))
	entity.free_requested.connect(_on_entity_free_requested.bind(entity))
	_entities_container.add_child(entity)
	
	_entity_map[pos] = entity
	
	if entity.process:
		_process_entities.append(entity)
	
	if entity.selectable:
		_selectable_entities.append(entity)
	
	entity._get_moore_neighbors = _get_moore_neighbors
	
	if _selected_entity == null:
		select_next_entity()


func remove_entity(entity: Entity) -> void:
	if entity.selectable:
		_selectable_entities.erase(entity)
	
	_entity_map.erase(entity.pos)
	entity.queue_free()
	
	if entity == _selected_entity:
		select_next_entity()


func simulate_move(current_pos: Vector2i, target_pos: Vector2i) -> bool:
	var dir := target_pos - current_pos
	
	var target_cell := get_cell(target_pos)
	var target_entity: Entity = _entity_map.get(target_pos)
	
	if target_cell == TILE_EMPTY and target_entity == null:
		return true
	
	# Action: Push other entity
	if target_entity != null:
		var current_entity: Entity = _entity_map.get(current_pos)
		
		if current_entity != null:
			current_entity.collide_with(target_entity)
			target_entity.collide_with(current_entity)
			
			if !current_entity.can_push(target_entity):
				return false
		
		if simulate_move(target_pos, target_pos + dir):
			move_cell(target_pos, target_pos + dir)
			return true
	
	return false


func move_cell(current_pos: Vector2i, target_pos: Vector2i) -> void:
	# Check if entity should be moved
	if current_pos in _entity_map:
		var current_entity := _entity_map[current_pos] as Entity
		
		current_entity.pos = target_pos
		current_entity.position = _block_layer.map_to_local(target_pos)
		
		_entity_map.erase(current_pos)
		_entity_map[target_pos] = current_entity
		
		if current_entity == _selected_entity:
			update_hints()
		
		return
	
	# Otherwise move tile
	var current_cell := get_cell(current_pos)
	if current_cell != TILE_EMPTY:
		set_cell(current_pos, TILE_EMPTY)
		set_cell(target_pos, current_cell)
		return


func get_cell(pos: Vector2i) -> Vector2i:
	return _block_layer.get_cell_atlas_coords(pos)


func set_cell(pos: Vector2i, cell: Vector2i) -> void:
	_block_layer.set_cell(pos, 0, cell)


func _on_entity_move_requested(dir: Vector2i, entity: Entity):
	var current_pos := entity.pos
	var target_pos := current_pos + dir
	
	if simulate_move(current_pos, target_pos):
		move_cell(current_pos, target_pos)


func _on_entity_free_requested(entity: Entity):
	remove_entity(entity)
