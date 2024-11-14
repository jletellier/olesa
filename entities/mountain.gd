extends "res://entities/entity.gd"


@export var processing_count := 3

var processing_step := 0
var has_worker := false


func process_logic() -> void:
	if has_worker:
		if processing_step >= processing_count:
			print("finished")
			processing_step = 0
		
		print(processing_step)
		processing_step += 1
