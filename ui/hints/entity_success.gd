extends Node2D


@onready var _animated_sprite := $"AnimatedSprite2D" as AnimatedSprite2D


func animate() -> void:
	_animated_sprite.frame = 0
	_animated_sprite.play()
