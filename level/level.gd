extends Node2D


const Map := preload("res://maps/map.gd")
const MapDB := preload("res://maps/map_db.gd")
const GameState := preload("res://level/game_state.gd")

const SAVEGAME_PATH := "user://savegame.tres"
const UI_OFFSET := Vector2i(0, 0)
const INPUT_ECHO_DELTA_INITIAL := 0.28
const INPUT_ECHO_DELTA := 0.18
const INPUT_ACTIONS := [
	"game_undo",
	"game_right",
	"game_down",
	"game_left",
	"game_up",
]

var _map_just_loaded := true
var _map_just_finished := false
var _last_input_action := ""
var _last_input_delta := 0.0
var _is_first_echo := true
var _game_state := GameState.new()
var _loaded_map_id := 0

@onready var _root_window := get_tree().root
@onready var _map := $"Map" as Map
@onready var _camera := $"Camera2D" as Camera2D
@onready var _map_finish_player := $"MapFinishPlayer" as AudioStreamPlayer
@onready var _map_finish_timer := $"MapFinishTimer" as Timer



func _ready() -> void:
	# Check if this is the right map, otherwise switch to map
	_load_game_state()
	if !OS.has_feature("editor") and _game_state.current_map_id != _loaded_map_id:
		_change_map.call_deferred(_game_state.current_map_id)
	else:
		_game_state.current_map_id = _loaded_map_id
	
	_root_window.size_changed.connect(_on_size_changed)
	_load_map()


func _process(delta: float) -> void:
	if _map_just_finished:
		return
	
	var next_input_action := ""
	for input_action in INPUT_ACTIONS:
		if Input.is_action_just_pressed(input_action):
			next_input_action = input_action
			_is_first_echo = true
			break
	
	if next_input_action == "" and _map_just_loaded:
		return
	_map_just_loaded = false
	
	_last_input_delta += delta
	var echo_delta := INPUT_ECHO_DELTA_INITIAL if _is_first_echo else INPUT_ECHO_DELTA
	var is_valid_delta := (_last_input_delta > echo_delta)
	
	var is_echo_input_action := false
	if next_input_action == "" and _last_input_action != "":
		is_echo_input_action = Input.is_action_pressed(_last_input_action)
		if is_echo_input_action:
			next_input_action = _last_input_action
	
	if next_input_action == "":
		for input_action in INPUT_ACTIONS:
			if Input.is_action_pressed(input_action):
				next_input_action = input_action
				break
	
	if next_input_action != _last_input_action or (is_echo_input_action and is_valid_delta):
		if is_echo_input_action:
			_is_first_echo = false
		
		_last_input_action = next_input_action
		_last_input_delta = 0.0
		
		match _last_input_action:
			"game_undo":
				_map.history_undo()
			"game_right":
				_map.process_action(Vector2i.RIGHT)
			"game_down":
				_map.process_action(Vector2i.DOWN)
			"game_left":
				_map.process_action(Vector2i.LEFT)
			"game_up":
				_map.process_action(Vector2i.UP)


func _input(event: InputEvent) -> void:
	if _map_just_finished:
		return
	
	if event.is_action_pressed("ui_focus_next"):
		_map.select_next()
	
	if event.is_action_pressed("game_next_map"):
		_change_map(_loaded_map_id + 1)
	elif event.is_action_pressed("game_prev_map"):
		_change_map(_loaded_map_id - 1)


func _change_map(id: int) -> void:
	if id < 0:
		id = 0
	
	if id >= MapDB.MAPS.size():
		print("Game finished")
		id = 0
	
	_loaded_map_id = id
	_save_game_state()
	
	var map_path := "res://maps/%s.tscn" % [MapDB.MAPS[_loaded_map_id]]
	var MapScene := load(map_path) as PackedScene
	var new_map := MapScene.instantiate()
	
	_unload_map()
	remove_child(_map)
	_map.queue_free()
	add_child(new_map)
	_map = new_map
	_load_map()


func _load_map() -> void:
	_map.goals_reached.connect(_on_map_goals_reached)
	_on_size_changed.call_deferred()
	_map_just_loaded = true
	_map_just_finished = false


func _unload_map() -> void:
	_map.goals_reached.disconnect(_on_map_goals_reached)


func _load_game_state() -> void:
	if FileAccess.file_exists(SAVEGAME_PATH):
		var loaded_res := ResourceLoader.load(SAVEGAME_PATH)
		if loaded_res is GameState:
			_game_state = loaded_res


func _save_game_state() -> void:
	_game_state.current_map_id = _loaded_map_id
	ResourceSaver.save(_game_state, SAVEGAME_PATH)


func _on_size_changed() -> void:	
	# Center camera on main tile map layer
	var map_size := _map.get_map_size()
	var tile_size := _map.get_tile_size()
	var pixel_size := Vector2i(map_size * tile_size) - UI_OFFSET
	_camera.position = pixel_size / 2
	
	# Change window scale if necessary
	var window_size := _root_window.size
	var new_scale_factor := ceili(_root_window.content_scale_factor)
	
	var test_scale_size := pixel_size * new_scale_factor
	if test_scale_size.x > window_size.x or test_scale_size.y > window_size.y:
		new_scale_factor = max(new_scale_factor - 1, 1)
	else:
		test_scale_size = pixel_size * (new_scale_factor + 1)
		if test_scale_size.x < window_size.x and test_scale_size.y < window_size.y:
			new_scale_factor = min(new_scale_factor + 1, 12)
	
	_root_window.content_scale_factor = new_scale_factor


func _on_map_goals_reached() -> void:
	_map_just_finished = true
	_map_finish_player.play()
	_map_finish_timer.timeout.connect(func():
		_change_map(_loaded_map_id + 1)
	, CONNECT_ONE_SHOT)
	_map_finish_timer.start()
