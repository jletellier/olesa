extends Node2D


const Map := preload("res://maps/map.gd")

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
var _last_input_action := ""
var _last_input_delta := 0.0
var _is_first_echo := true

@onready var _root_window := get_tree().root
@onready var _map := $"Map" as Map
@onready var _camera := $"Camera2D" as Camera2D


func _ready() -> void:
	_root_window.size_changed.connect(_on_size_changed)
	_load_map()


func _process(delta: float) -> void:
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
	if event.is_action_pressed("ui_focus_next"):
		_map.select_next()


func _change_map(id: String) -> void:
	var map_path := "res://maps/map_%s.tscn" % [id]
	var MapScene := load(map_path) as PackedScene
	var new_map := MapScene.instantiate()
	
	_unload_map()
	remove_child(_map)
	_map.queue_free()
	add_child(new_map)
	_map = new_map
	_load_map()


func _load_map() -> void:
	_on_size_changed.call_deferred()
	_map_just_loaded = true


func _unload_map() -> void:
	pass


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
