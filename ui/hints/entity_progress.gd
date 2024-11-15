extends Node2D


const progress_count := 4

var progress := 0:
	set = _set_progress

@onready var _animated_sprite := $"AnimatedSprite2D" as AnimatedSprite2D


func _set_progress(value: int) -> void:
	progress = clampi(value, 0, progress_count)
	
	if _animated_sprite != null:
		var anim_str := "default" if progress == 0 else ("step_" + str(progress))
		
		_animated_sprite.frame = 0
		_animated_sprite.play(anim_str)
