extends Node2D


const TILE_EMPTY := Vector2i(-1, -1)
const TILE_WALL := Vector2i(0, 0)
const TILE_PLAYER := Vector2i(1, 0)
const TILE_OBJECT := Vector2i(2, 0)
const TILE_SURFACE := Vector2i(3, 0)
const TILE_SURFACE_OBJECT := Vector2i(4, 0)
const TILE_WALL_CRACKED := Vector2i(5, 0)
const TILE_DOOR := Vector2i(6, 0)
const TILE_TOOL := Vector2i(7, 0)

const EntitySelect := preload("res://ui/hints/entity_select.gd")

var _selected_entity_pos := Vector2i.MIN

@onready var _block_layer := $"BlockLayer" as TileMapLayer
@onready var _hint_entity_select := $HintEntitySelect as EntitySelect


func _ready() -> void:
	select_next_player()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		select_next_player()
	
	if event.is_action_pressed("game_right"):
		move_selected_entity(Vector2i.RIGHT)
	elif event.is_action_pressed("game_down"):
		move_selected_entity(Vector2i.DOWN)
	elif event.is_action_pressed("game_left"):
		move_selected_entity(Vector2i.LEFT)
	elif event.is_action_pressed("game_up"):
		move_selected_entity(Vector2i.UP)


func _simulate_physics(current_pos: Vector2i, target_pos: Vector2i) -> bool:
	var dir := target_pos - current_pos
	
	var current_cell := get_cell(current_pos)
	var target_cell := get_cell(target_pos)
	
	if target_cell == TILE_EMPTY:
		return true
	
	# Action: Two players colliding causes both to dissolve
	if target_cell == TILE_PLAYER and current_cell == TILE_PLAYER:
		set_cell(current_pos, TILE_EMPTY)
		set_cell(target_pos, TILE_EMPTY)
		select_next_player()
		return false
	
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
	
	# Action: Moving object
	if target_cell == TILE_OBJECT:
		if _simulate_physics(target_pos, target_pos + dir):
			move_cell(target_pos, target_pos + dir)
			return true
	
	return false


func update_hints(animate := false) -> void:
	if _selected_entity_pos == Vector2i.MIN:
		_hint_entity_select.visible = false
		return
	
	_hint_entity_select.visible = true
	_hint_entity_select.position = _block_layer.map_to_local(_selected_entity_pos)
	if animate:
		_hint_entity_select.animate()


func select_next_player() -> void:
	var used_cells := _block_layer.get_used_cells_by_id(0, TILE_PLAYER)
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


func move_selected_entity(dir: Vector2i) -> void:
	if _selected_entity_pos == Vector2i.MIN:
		return
	
	var current_pos := _selected_entity_pos
	var target_pos := _selected_entity_pos + dir
	
	if _simulate_physics(current_pos, target_pos):
		move_cell(current_pos, target_pos)


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
