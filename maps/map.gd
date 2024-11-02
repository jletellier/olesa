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

var _current_player_pos := Vector2i(-1, -1)

@onready var _block_layer := $"BlockLayer" as TileMapLayer


func _ready() -> void:
	select_next_player()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_right"):
		move_current_player(Vector2i.RIGHT)
	elif event.is_action_pressed("game_down"):
		move_current_player(Vector2i.DOWN)
	elif event.is_action_pressed("game_left"):
		move_current_player(Vector2i.LEFT)
	elif event.is_action_pressed("game_up"):
		move_current_player(Vector2i.UP)


func _simulate_physics(current_pos: Vector2i, target_pos: Vector2i) -> bool:
	var dir := target_pos - current_pos
	
	var current_cell := get_cell(current_pos)
	var target_cell := get_cell(target_pos)
	
	if target_cell == TILE_EMPTY:
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


func select_next_player() -> void:
	var used_cells := _block_layer.get_used_cells_by_id(0, TILE_PLAYER)
	for used_cell in used_cells:
		if used_cell != _current_player_pos:
			_current_player_pos = used_cell
			break


func move_current_player(dir: Vector2i) -> void:
	if _current_player_pos == Vector2i(-1, -1):
		return
	
	var current_pos := _current_player_pos
	var target_pos := _current_player_pos + dir
	
	if _simulate_physics(current_pos, target_pos):
		move_cell(current_pos, target_pos)
		_current_player_pos = target_pos


func move_cell(current_pos: Vector2i, target_pos: Vector2i) -> void:
	var current_cell := get_cell(current_pos)
	set_cell(current_pos, TILE_EMPTY)
	set_cell(target_pos, current_cell)


func get_cell(pos: Vector2i) -> Vector2i:
	return _block_layer.get_cell_atlas_coords(pos)


func set_cell(pos: Vector2i, cell: Vector2i) -> void:
	_block_layer.set_cell(pos, 0, cell)
