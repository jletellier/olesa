extends Node2D


const Entity := preload("res://entities/entity.gd")
const EntitySelect := preload("res://ui/hints/entity_select.gd")
const LawaScene := preload("res://entities/lawa.tscn")
const JoScene := preload("res://entities/jo.tscn")

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

const ENTITY_LAWA := Vector2i(1, 0)
const ENTITY_JO := Vector2i(0, 1)

const HINT_DOOR := Vector2i(6, 1)

const ENTITY_SCENES := {
	Vector2i(1, 0): LawaScene,
	Vector2i(0, 1): JoScene
}

var _entity_map := {} # Typing: Dictionary[Vector2i, Entity]
var _selected_entity: Entity

@onready var _block_layer := $"BlockLayer" as TileMapLayer
@onready var _hint_layer := $"HintLayer" as TileMapLayer
@onready var _entities_container := $"Entities" as Node2D
@onready var _hint_entity_select := $Hints/EntitySelect as EntitySelect


func _ready() -> void:
	_convert_entities()


func _convert_entities() -> void:
	var cell_positions := _block_layer.get_used_cells()
	for cell_pos in cell_positions:
		var cell := _block_layer.get_cell_atlas_coords(cell_pos)
		if cell in ENTITY_SCENES:
			# Add entity as scene
			var entity_scene := ENTITY_SCENES[cell] as PackedScene
			var entity := entity_scene.instantiate() as Entity
			entity.position = _block_layer.map_to_local(cell_pos)
			_entities_container.add_child(entity)
			
			# Store map of entities
			entity.pos = cell_pos
			_entity_map[cell_pos] = entity
			
			# Remove tile, since it's no longer needed
			_block_layer.erase_cell(cell_pos)
	
	if _selected_entity == null:
		select_next_entity()


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
	
	if action_dir != Vector2i.ZERO:
		action_selected_entity(action_dir)


func _simulate_physics(current_pos: Vector2i, target_pos: Vector2i) -> bool:
	var dir := target_pos - current_pos
	
	var current_cell := get_cell(current_pos)
	var target_cell := get_cell(target_pos)
	
	if target_cell == TILE_EMPTY:
		return true
	
	# Action: Two Lawas colliding causes both to dissolve
	if target_cell == ENTITY_LAWA and current_cell == ENTITY_LAWA:
		set_cell(current_pos, TILE_EMPTY)
		set_cell(target_pos, TILE_EMPTY)
		select_next_entity()
		return false
	
	## Action: Lawa can push Jo
	#if target_cell == ENTITY_JO and current_cell == ENTITY_LAWA:
		#if _simulate_physics(target_pos, target_pos + dir):
			#move_cell(target_pos, target_pos + dir)
			#return true
		#return false
	
	# Action: Object colliding with cracked wall
	if target_cell == TILE_WALL_CRACKED and current_cell == TILE_OBJECT:
		set_cell(current_pos, TILE_EMPTY)
		set_cell(target_pos, TILE_EMPTY)
		return true
	
	# Action: Object moving onto surface
	if target_cell == TILE_SURFACE and current_cell == TILE_OBJECT:
		set_cell(current_pos, TILE_SURFACE_OBJECT)
		set_cell(target_pos, TILE_EMPTY)
		return true
	
	# Action: In all other cases, pushing target cell
	if target_cell in [TILE_OBJECT, ENTITY_LAWA, ENTITY_JO]:
		if _simulate_physics(target_pos, target_pos + dir):
			move_cell(target_pos, target_pos + dir)
			return true
	
	return false


func _simulate_logic() -> void:
	# Process: Open/close doors depending on whether a tool is nearby
	var used_positions := _hint_layer.get_used_cells_by_id(0, HINT_DOOR)
	for hint_pos in used_positions:
		var block_cell := get_cell(hint_pos)
		if block_cell != TILE_DOOR and block_cell != TILE_EMPTY:
			continue
		
		var has_tool := false
		var surrounding_positions := _hint_layer.get_surrounding_cells(hint_pos)
		for surrounding_pos in surrounding_positions:
			var surrounding_cell := get_cell(surrounding_pos)
			if surrounding_cell == TILE_CONTAINER_TOOL:
				has_tool = true
				break
		
		set_cell(hint_pos, TILE_EMPTY if has_tool else TILE_DOOR)


func update_hints(animate := false) -> void:
	if _selected_entity == null:
		_hint_entity_select.visible = false
		return
	
	_hint_entity_select.visible = true
	_hint_entity_select.position = _block_layer.map_to_local(_selected_entity.pos)
	if animate:
		_hint_entity_select.animate()


func select_next_entity() -> void:
	if _entity_map.is_empty():
		return
	
	var current_pos_idx := -1
	var entity_positions := _entity_map.keys()
	
	if _selected_entity != null:
		for i in range(entity_positions.size()):
			var entity_pos := entity_positions[i] as Vector2i
			if entity_pos == _selected_entity.pos:
				current_pos_idx = i
				break
	
	var next_pos_idx := (current_pos_idx + 1) % entity_positions.size()
	_selected_entity = _entity_map[entity_positions[next_pos_idx]]
	
	update_hints(true)


func action_selected_entity(dir: Vector2i) -> void:
	if _selected_entity == null:
		return
	
	var current_pos := _selected_entity.pos
	var target_pos := _selected_entity.pos + dir
	
	match _selected_entity.type:
		"lawa":
			if _simulate_physics(current_pos, target_pos):
				move_cell(current_pos, target_pos)
		"jo":
			var target_cell := get_cell(target_pos)
			if target_cell == TILE_CONTAINER_TOOL:
				set_cell(target_pos, TILE_CONTAINER)
			elif target_cell == TILE_CONTAINER:
				set_cell(target_pos, TILE_CONTAINER_TOOL)
	
	_simulate_logic()


func move_cell(current_pos: Vector2i, target_pos: Vector2i) -> void:
	var current_cell := get_cell(current_pos)
	var target_cell := get_cell(target_pos)
	
	if target_cell != TILE_EMPTY:
		return
	
	if current_pos == _selected_entity.pos:
		_selected_entity.pos = target_pos
		_selected_entity.position = _block_layer.map_to_local(target_pos)
		update_hints()
		return
	
	if current_cell != TILE_EMPTY:
		set_cell(current_pos, TILE_EMPTY)
		set_cell(target_pos, current_cell)
		return


func get_cell(pos: Vector2i) -> Vector2i:
	return _block_layer.get_cell_atlas_coords(pos)


func set_cell(pos: Vector2i, cell: Vector2i) -> void:
	_block_layer.set_cell(pos, 0, cell)
