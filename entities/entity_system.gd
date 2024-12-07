extends Node


const Entity := preload("res://entities/entity.gd")

var entity: Entity


@warning_ignore("unused_parameter")
func init(data := {}) -> void:
	pass


func serialize() -> Dictionary:
	return {}


func start() -> void:
	pass


func tick() -> void:
	pass


@warning_ignore("unused_parameter")
func step_process(delta: float, duration: float) -> void:
	pass


@warning_ignore("unused_parameter")
func action(dir: Vector2i) -> bool:
	return false


func destroy() -> void:
	pass


func emit_history_transaction(attribute, value) -> void:
	entity.history_transaction.emit(entity, name, attribute, value)
