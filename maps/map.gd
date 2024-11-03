extends Node2D


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

const ENTITY_LAWA := Vector2i(1, 0)
const ENTITY_JO := Vector2i(0, 1)

const EntitySelect := preload("res://ui/hints/entity_select.gd")

var _selected_entity_pos := Vector2i.MIN

@onready var _block_layer := $"BlockLayer" as TileMapLayer
@onready var _hint_layer := $"HintLayer" as TileMapLayer
@onready var _hint_entity_select := $HintEntitySelect as EntitySelect


func _ready() -> void:
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
	if _selected_entity_pos == Vector2i.MIN:
		_hint_entity_select.visible = false
		return
	
	_hint_entity_select.visible = true
	_hint_entity_select.position = _block_layer.map_to_local(_selected_entity_pos)
	if animate:
		_hint_entity_select.animate()


func select_next_entity() -> void:
	var used_cells: Array[Vector2i] = []
	used_cells.append_array(_block_layer.get_used_cells_by_id(0, ENTITY_LAWA))
	used_cells.append_array(_block_layer.get_used_cells_by_id(0, ENTITY_JO))
	
	if used_cells.is_empty():
		return
	
	var current_cel_idx := -1
	for i in range(used_cells.size()):
		var used_cell := used_cells[i]
		if used_cell == _selected_entity_pos:
			current_cel_idx = i
			break
	
	var next_entity_pos := (current_cel_idx + 1) % used_cells.size()
	_selected_entity_pos = used_cells[next_entity_pos]
	
	update_hints(true)


func action_selected_entity(dir: Vector2i) -> void:
	if _selected_entity_pos == Vector2i.MIN:
		return
	
	var selected_entity := get_cell(_selected_entity_pos)
	var current_pos := _selected_entity_pos
	var target_pos := _selected_entity_pos + dir
	
	match selected_entity:
		ENTITY_LAWA: 
			if _simulate_physics(current_pos, target_pos):
				move_cell(current_pos, target_pos)
		ENTITY_JO:
			var target_cell := get_cell(target_pos)
			if target_cell == TILE_CONTAINER_TOOL:
				set_cell(target_pos, TILE_CONTAINER)
			elif target_cell == TILE_CONTAINER:
				set_cell(target_pos, TILE_CONTAINER_TOOL)
	
	_simulate_logic()


func move_cell(current_pos: Vector2i, target_pos: Vector2i) -> void:
	var current_cell := get_cell(current_pos)
	
	set_cell(current_pos, TILE_EMPTY)
	set_cell(target_pos, current_cell)
	
	if current_pos == _selected_entity_pos:
		_selected_entity_pos = target_pos
		update_hints()


func get_cell(pos: Vector2i) -> Vector2i:
	return _block_layer.get_cell_atlas_coords(pos)


func set_cell(pos: Vector2i, cell: Vector2i) -> void:
	_block_layer.set_cell(pos, 0, cell)
