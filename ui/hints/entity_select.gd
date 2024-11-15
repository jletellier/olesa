extends Node2D


@onready var _animated_sprite := $"AnimatedSprite2D" as AnimatedSprite2D
@onready var _audio_player := $"AudioStreamPlayer" as AudioStreamPlayer


func animate() -> void:
	_animated_sprite.frame = 0
	_animated_sprite.play()
	_audio_player.play()
