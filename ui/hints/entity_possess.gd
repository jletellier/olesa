extends Node2D


var active := false:
	set = _set_active

@onready var _animated_sprite := $"AnimatedSprite2D" as AnimatedSprite2D


func _set_active(value: bool) -> void:
	active = value
	
	if _animated_sprite != null:
		_animated_sprite.frame = 0
		if active:
			_animated_sprite.play()
		else:
			_animated_sprite.play_backwards()
