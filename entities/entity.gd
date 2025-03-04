extends Node2D


const Map := preload("res://maps/map.gd")
const Entity := preload("res://entities/entity.gd")
const EntitySystem := preload("res://entities/entity_system.gd")
const EntityDB := preload("res://entities/entity_db.gd")
const EntitySelect := preload("res://ui/hints/entity_select.gd")

@warning_ignore("unused_signal")
signal history_transaction(entity: Entity, system: String, attribute: String, value: Variant)

var type: StringName

var pos := Vector2i.ZERO:
	set = _set_pos

var layer := 0:
	set = _set_layer

var map: Map
var is_running := false

var _systems: Array[EntitySystem] = []
var _system_map := {} # Typing: Dictionary[String, EntitySystem]
var _first_run := true


func _ready() -> void:
	for child in get_children():
		if child is EntitySystem:
			child.entity = self
			_systems.append(child)
			_system_map[child.name] = child


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for system in _systems:
			system.destroy()


func init(data := {}) -> void:
	for system in _systems:
		var system_data: Dictionary = data.get(system.name, {})
		system.init(system_data)


func serialize() -> Dictionary:
	var data := {}

	for system in _systems:
		var system_data := system.serialize()
		if !system_data.is_empty():
			data[system.name] = system_data

	return data


func tick() -> void:
	if _first_run:
		for system in _systems:
			system.start()
		is_running = true
		_first_run = false
	elif is_running:
		for system in _systems:
			system.tick()


func step_process(delta: float, duration: float) -> void:
	for system in _systems:
		system.step_process(delta, duration)


func action(dir: Vector2i) -> bool:
	var successful := false
	if is_running:
		for system in _systems:
			if system.action(dir):
				successful = true
	return successful


func get_system(key: String, default: Variant = null) -> EntitySystem:
	return _system_map.get(key, default)


func _set_pos(value: Vector2i) -> void:
	var old_pos := pos
	pos = value
	
	if map != null and pos != old_pos:
		map.move_entity(self, old_pos, layer)


func _set_layer(value: int) -> void:
	var old_layer := layer
	layer = value
	
	if map != null and layer != old_layer:
		map.move_entity(self, pos, old_layer)
