extends "res://entities/entity.gd"


const EntityProgress := preload("res://ui/hints/entity_progress.gd")

@export var processing_count := 3

var processing_step := 0
var has_worker := false:
	set = _set_has_worker

@onready var _hint_progress := $"HintProgress" as EntityProgress


func process_logic() -> void:
	if has_worker:
		processing_step += 1
		
		_hint_progress.progress = processing_step
		
		if processing_step >= processing_count:
			print("finished")
			processing_step = 0


func _set_has_worker(value: bool) -> void:
	has_worker = value
	
	if _hint_progress != null:
		processing_step = 0
		_hint_progress.visible = has_worker
		_hint_progress.progress = 0
